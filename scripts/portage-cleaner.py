#!/usr/bin/env python3
import sys
import collections
import shutil
import re
import os
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)

def get_sort_key(atom):
    """
    Extracts the base package name for sorting purposes.
    Example: '>=dev-lang/python-3.10' -> 'dev-lang/python'
    """
    clean_atom = re.sub(r'^[<>=!~]+', '', atom)
    clean_atom = re.split(r'-\d', clean_atom)[0]
    return clean_atom.lower()

def process_path(target_path):
    if not os.path.exists(target_path):
        logger.error(f"Path not found: {target_path}")
        return

    is_dir = os.path.isdir(target_path)
    consolidated = collections.defaultdict(set)
    verbatim_lines = []
    files_to_read = []

    if is_dir:
        logger.info(f"Scanning directory: {target_path}")
        for f in sorted(os.listdir(target_path)):
            full_p = os.path.join(target_path, f)
            if os.path.isfile(full_p) and not f.endswith(".bak"):
                files_to_read.append(full_p)
    else:
        files_to_read.append(target_path)

    for filepath in files_to_read:
        logger.info(f"Reading: {filepath}")
        with open(filepath, 'r') as f:
            for line_num, line in enumerate(f, 1):
                stripped = line.strip()
                if not stripped or stripped.startswith('#'):
                    continue

                parts = stripped.split('#')[0].split()
                if not parts:
                    continue

                atom = parts[0]
                flags = parts[1:]

                if any(':' in flag for flag in flags):
                    logger.debug(f"Line {line_num}: Moving to verbatim (contains ':')")
                    verbatim_lines.append(stripped)
                else:
                    consolidated[atom].update(flags)

    if not is_dir:
        backup = target_path + ".bak"
        shutil.copy2(target_path, backup)
        logger.info(f"Backup created: {backup}")
        output_path = target_path
    else:
        output_path = target_path + ".consolidated"
        logger.info(f"Directory mode: Writing to {output_path}")

    sorted_atoms = sorted(consolidated.keys(), key=get_sort_key)

    try:
        with open(output_path, 'w') as f:
            for line in verbatim_lines:
                f.write(line + '\n')
            
            if verbatim_lines and sorted_atoms:
                f.write('\n')

            for atom in sorted_atoms:
                flags_list = sorted(list(consolidated[atom]))
                output_line = f"{atom} {' '.join(flags_list)}"
                f.write(output_line + '\n')
                logger.info(f"Consolidated: {atom}")

        logger.info(f"Successfully processed {len(sorted_atoms)} unique atoms.")
        
    except IOError as e:
        logger.error(f"Failed to write output: {e}")

if __name__ == "__main__":
    if os.geteuid() != 0:
        logger.info("Elevating privileges via sudo...")
        os.execvp("sudo", ["sudo", "python3"] + sys.argv)

    target = sys.argv[1] if len(sys.argv) > 1 else "/etc/portage/package.use"
    process_path(target)

