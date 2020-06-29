//copyright 2020 oldtopman

//args - rdi, rsi, rdx, rcx, r8, r9, stack
//rval - {rdx, rax} - rdx (higher bits) usually unused
//preserve - rbx, rsp, rbp, r12, r13, r14, r15
//modify - rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11

//syscall reference https://opensource.apple.com/source/xnu/xnu-6153.81.5/bsd/kern/syscalls.master.auto.html

//void exit(int rval);
.macro syscall_exit rval:req
        movl	\rval, %edi
        movq	$0x2000001, %rax
        syscall
.endm

//user_ssize_t read(int fd, user_addr_t cbuf, user_size_t nbyte)
.macro syscall_read fd:req cbuf:req nbyte:req
        movl	\fd, %edi
        movq	\cbuf, %rsi
        movq	\nbyte, %rdx
        movq	$0x2000003, %rax
        syscall
.endm

//user_ssize_t write(int fd, user_addr_t cbuf, user_size_t nbyte);
.macro syscall_write fd:req cbuf:req nbyte:req
        movl	\fd, %edi
        movq	\cbuf, %rsi
        movq	\nbyte, %rdx
        movq	$0x2000004, %rax
        syscall
.endm

//int open(user_addr_t path, int flags, int mode)
.macro syscall_open path:req flags:req mode:req
        movq	\path, %rdi
        movl	\flags, %esi
        movl	\mode, %edx
        movq	$0x2000005, %rax
        syscall
.endm

//int socket(int domain, int type, int protocol)
.macro syscall_socket domain:req type:req protocol:req
        movl	\domain, %edi
        movl	\type, %esi
        movl	\protocol, %edx
        movq	$0x2000061, %rax
        syscall
.endm

//int bind(int s, caddr_t name, socklen_t namelen)
.macro syscall_bind s:req name:req namelen:req
        movl	\s, %edi
        movq	\name, %rsi
        movl	\namelen, %edx
        movq	$(0x2000000 | 104), %rax
        syscall
.endm

//int setsockopt(int s, int level, int name, caddr_t val, socklen_t valsize)
.macro syscall_setsockopt s:req level:req name:req val:req valsize:req
        movl	\s, %edi
        movl	\level, %esi
        movl	\name, %edx
        movq	\val, %rcx
        movl	\valsize, %e8d
        movq	$(0x2000000 | 105), %rax
        syscall
.endm

//int listen(int s, int backlog)
.macro syscall_listen s:req backlog:req 
        movl	\s, %edi
        movl	\backlog, %esi
        movq	$(0x2000000 | 106), %rax
        syscall
.endm

//int poll(struct pollfd *fds, u_int nfds, int timeout)
.macro syscall_poll fds:req nfds:req timeout:req
	movq	\fds, %rdi
	movl	\nfds, %esi
	movl	\timeout, %edx
	movq $(0x20000000 | 230), %rax
	syscall
.endm

