//copyright 2020 oldtopman

//args - rdi, rsi, rdx, rcx, r8, r9, stack
//rval - {rdx, rax} - rdx (higher bits) usually unused
//preserve - rbx, rsp, rbp, r12, r13, r14, r15
//modify - rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11

//syscall reference https://opensource.apple.com/source/xnu/xnu-6153.81.5/bsd/kern/syscalls.master.auto.html

//void exit(int rval);
.macro syscall_exit rval:req
        movq \rval, %rdi
        movq $0x2000001, %rax
        syscall
.endm

//user_ssize_t read(int fd, user_addr_t cbuf, user_size_t nbyte)
.macro syscall_read fd:req cbuf:req nbyte:req
        movq \fd, %rdi
        movq \cbuf, %rsi
        movq \nbyte, %rdx
        movq $0x2000003, %rax
        syscall
.endm

//user_ssize_t write(int fd, user_addr_t cbuf, user_size_t nbyte);
.macro syscall_write fd:req cbuf:req nbyte:req
        movq \fd, %rdi
        movq \cbuf, %rsi
        movq \nbyte, %rdx
        movq $0x2000004, %rax
        syscall
.endm

//int open(user_addr_t path, int flags, int mode)
.macro syscall_open path:req flags:req mode:req
        movq \path, %rdi
        movq \flags, %rsi
        movq \mode, %rdx
        movq $0x2000005, %rax
        syscall
.endm

//int socket(int domain, int type, int protocol)
.macro syscall_socket domain:req type:req protocol:req
        movq \domain, %rdi
        movq \type, %rsi
        movq \protocol, %rdx
        movq $0x2000061, %rax
        syscall
.endm

