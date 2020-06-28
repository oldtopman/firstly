//copyright 2020 oldtopman

#include "syscalls.S"

#define SOCK_PENDING_CONNECTIONS 10

//some of this can probably be moved to bss
.section __DATA, __data
log_fd:		.quad	0

sock_master:	.quad	0

str_logname:	.asciz	"firstly.log\0"
str_logstart:	.asciz	"Logging started\n"
str_logstop:	.asciz	"Logging stopped\n"
str_logretval:	.asciz	"fatal: function returned negative\n"

//sockaddr_in
sin_len:	.byte	16	//sizeof(sockaddr_in) including this line
sin_family:	.byte	2	//AF_INET
sin_port:	.short	0x7a1e	//htons(7770)
sin_addr:	.long	0	//INADDR_ANY
sin_zero:	.quad	0	//zero

.section __TEXT, __text

//Not used everywhere, just when initializing program-critical things
rax_not_negative:
	test	%rax, %rax
	jns	2f
	cmpq	$0, log_fd(%rip)
	jng	1f
	syscall_write	log_fd(%rip), str_logretval@GOTPCREL(%rip), $34
1:
	syscall_exit	$1
2:
	ret

init_logging:
	syscall_open	str_logname@GOTPCREL(%rip), $(0x1 | 0x8 | 0x200), $0644
	call	rax_not_negative
	movq	%rax, log_fd(%rip)
	syscall_write	log_fd(%rip), str_logstart@GOTPCREL(%rip), $16
	call	rax_not_negative
	ret

init_msocket:
	syscall_socket	$2, $1, $0
	call	rax_not_negative
	movq	%rax, sock_master(%rip)

	//syscall_setsockopt

	syscall_bind	sock_master(%rip), sin_len@GOTPCREL(%rip), $16
	call	rax_not_negative
	
	syscall_listen	sock_master(%rip), $SOCK_PENDING_CONNECTIONS
	call	rax_not_negative

	ret

msocket_loop:
	//prep for syscall poll
	//syscall_poll
	//iterate over sockets
	ret

shutdown:
	syscall_write	log_fd(%rip), str_logstop@GOTPCREL(%rip), $16
	syscall_exit $0
	ret

.globl _main
_main:
	call init_logging
	call init_msocket
	call msocket_loop
	call shutdown

