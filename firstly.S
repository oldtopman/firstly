//copyright 2020 oldtopman

#include "syscalls.S"

#define SOCK_PENDING_CONNECTIONS 10

.section __BSS, __bss
.comm	sock_buf, 524288
.comm	sock_list, 8192 //used for monitoring active connections

//some of this can probably be moved to bss
.section __DATA, __data
log_fd:		.long	0

sock_master:	.long	0

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

socklist_clear:
	//eax - sock
	//cl  - used for shlb
	//edi - byte offset
	//rsi - pointer to correct byte
	//dil - one bit indicating sock
	//dl  - workspace for correcting bit
	movl	%eax, %edi	// copy sock into edi
	movb	%al, %cl	// prepare cl for the shl later on
	shr	$3, %edi	// find byte offset in edi
	movq	sock_list@GOTPCREL(%rip), %rsi // load rsi with sock_list addr
	addq	%rdi, %rsi	// add byte offset to sock_list addr
	movb	$1, %dil	// put one bit in dil
	shlb	%cl, %dil	// move it to the correct spot
	movb	(%rsi), %dl	// load target byte into dl
	movb	(%rsi), %dl	// load target byte into dl
	xorb	$0xff, %dil	// toggle all bits in dil
	andb	%dil, %dl	// set bit
	movb	%dl, (%rsi)	// store modified bit into dl
	ret

socklist_isset:
	//eax - sock
	//cl  - used for shlb
	//edi - byte offset
	//rsi - pointer to correct byte
	//dil - one bit indicating sock
	//dl  - workspace for correcting bit
	movl	%eax, %edi	// copy sock into edi
	movb	%al, %cl	// prepare cl for the shl later on
	shr	$3, %edi	// find byte offset in edi
	movq	sock_list@GOTPCREL(%rip), %rsi // load rsi with sock_list addr
	addq	%rdi, %rsi	// add byte offset to sock_list addr
	movb	$1, %dil	// put one bit in dil
	shlb	%cl, %dil	// move it to the correct spot
	movb	(%rsi), %dl	// load target byte into dl
	andb	%dil, %dl	// compare bits
	xor	%rax, %rax	// clear rax
	movb	%dl, %al	// store the output in rax
	ret

socklist_set: //add eax to the socklist
	//eax - sock
	//cl  - used for shlb
	//edi - byte offset
	//rsi - pointer to correct byte
	//dil - one bit indicating sock
	//dl  - workspace for correcting bit
	movl	%eax, %edi	// copy sock into edi
	movb	%al, %cl	// prepare cl for the shl later on
	shr	$3, %edi	// find byte offset in edi
	movq	sock_list@GOTPCREL(%rip), %rsi // load rsi with sock_list addr
	addq	%rdi, %rsi	// add byte offset to sock_list addr
	movb	$1, %dil	// put one bit in dil
	shlb	%cl, %dil	// move it to the correct spot
	movb	(%rsi), %dl	// load target byte into dl
	or	%dil, %dl	// set bit
	movb	%dl, (%rsi)	// store modified bit into dl
	ret

socklist_zero:
	xor	%rax, %rax //zero
	xor	%rdi, %rdi //counter
	movq	sock_list@GOTPCREL(%rip), %rsi //pointer to word to be erased
1:
	cmpq	$1024, %rdi
	je	2f
	incq	%rdi
	movq	%rax, (%rsi)
	addq	$8, %rsi
2:
	ret

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
	movl	%eax, log_fd(%rip)
	syscall_write	log_fd(%rip), str_logstart@GOTPCREL(%rip), $16
	call	rax_not_negative
	ret

init_msocket:
	syscall_socket	$2, $1, $0
	call	rax_not_negative
	movl	%eax, sock_master(%rip)

	//syscall_setsockopt

	syscall_bind	sock_master(%rip), sin_len@GOTPCREL(%rip), $16
	call	rax_not_negative
	
	syscall_listen	sock_master(%rip), $SOCK_PENDING_CONNECTIONS
	call	rax_not_negative

	ret

msocket_loop:
	//initialize sock_list
	call	socklist_zero
	movl	sock_master(%rip), %eax 
	call	socklist_set

	//prep sock_buf

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

