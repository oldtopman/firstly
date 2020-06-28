//copyright 2020 oldtopman

#include "syscalls.S"

.section __DATA, __data
	return_well_value:	.quad	8

.section __TEXT, __text

return_well:
	syscall_exit return_well_value(%rip)
	ret

.globl _main
_main:
	call return_well

