/* ric_disabler_mod */

/*
 * Copyright (C) 2014 CUBE
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/kallsyms.h>
#include <asm/mmu_writeable.h>

static int isnewric;
static unsigned long sony_ric_enabled_addr;
static unsigned long sony_ric_enabled_code[3];

static int return_zero(void) {
	return 0;
}

void replace_sony_ric_enabled(void) {
	unsigned long *funcaddr;

	funcaddr = (unsigned long *)sony_ric_enabled_addr;
	sony_ric_enabled_code[0] = *funcaddr;
	sony_ric_enabled_code[1] = *(funcaddr + 1);
	sony_ric_enabled_code[2] = *(funcaddr + 2);
	mem_text_write_kernel_word(funcaddr, 0xe59ff000);
	mem_text_write_kernel_word(funcaddr + 1, (unsigned long)return_zero);
	mem_text_write_kernel_word(funcaddr + 2, (unsigned long)return_zero);
}

void restore_sony_ric_enabled(void) {
	unsigned long *funcaddr;

	funcaddr = (unsigned long *)sony_ric_enabled_addr;
	mem_text_write_kernel_word(funcaddr, sony_ric_enabled_code[0]);
	mem_text_write_kernel_word(funcaddr + 1, sony_ric_enabled_code[1]);
	mem_text_write_kernel_word(funcaddr + 2, sony_ric_enabled_code[2]);
}

static int __init ric_disabler_mod_init(void) {
	unsigned long addr;

	pr_info("ric_disabler_mod: module loaded.\n");

	isnewric = 0;

	addr = kallsyms_lookup_name("sony_ric_enabled");
	if (addr != 0) {
		isnewric = 1;
		sony_ric_enabled_addr = addr;
		replace_sony_ric_enabled();
	}

	return 0;
}

static void __exit ric_disabler_mod_exit(void) {
	if (isnewric != 0) {
		restore_sony_ric_enabled();
	}

	pr_info("ric_disabler_mod: module removed.\n");
}

module_init(ric_disabler_mod_init);
module_exit(ric_disabler_mod_exit);

MODULE_AUTHOR("CUBE");
MODULE_DESCRIPTION("ric disabler");
MODULE_VERSION("0.1");
MODULE_LICENSE("GPL");
