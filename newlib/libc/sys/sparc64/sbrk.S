! sbrk() system call

#include "sys/syscallasm.h"

	DATA_SECTION
	ALIGN (4)

! CURBRK contains the current top of allocated space.
! END is a private symbol in svr4, but a public one in sunos4.
! FIXME: CURBRK is 4 bytes for now.


	GLOBAL (ASM_PRIVATE_SYMBOL (curbrk))
ASM_PRIVATE_SYMBOL (curbrk):
#ifdef __svr4__
	WORD (ASM_PRIVATE_SYMBOL (end))
#else
	WORD (ASM_SYMBOL (end))
#endif

	TEXT_SECTION
	ALIGN (4)
#ifdef REENT
	GLOBAL (ASM_SYMBOL (_sbrk_r))
ASM_SYMBOL (_sbrk_r):
	mov	%o0,%o5
	mov	%o1,%o0
#else
	GLOBAL (ASM_SYMBOL (sbrk))
ASM_SYMBOL (sbrk):
#endif
	add	%o0,7,%o0
	andn	%o0,7,%o0
	sethi	%hi (ASM_PRIVATE_SYMBOL (curbrk)),%o2
	lduw	[%o2+%lo (ASM_PRIVATE_SYMBOL (curbrk))],%o3
	add	%o3,7,%o3
	andn	%o3,7,%o3
	add	%o3,%o0,%o0
	mov	%o0,%o4
	mov	SYS_brk,%g1
	ta	SYSCALL_TRAP
	bcs	err
	nop
	stw	%o4,[%o2+%lo (ASM_PRIVATE_SYMBOL (curbrk))]
	jmpl	%o7+8,%g0
	mov	%o3,%o0

#ifdef REENT
	GLOBAL (ASM_SYMBOL (_brk_r))
ASM_SYMBOL (_brk_r):
	mov	%o0,%o5
	mov	%o1,%o0
#else
	GLOBAL (ASM_SYMBOL (brk))
ASM_SYMBOL (brk):
#endif
	add	%o0,7,%o0
	andn	%o0,7,%o0
	mov	%o0,%o2
	mov	SYS_brk,%g1
	ta	SYSCALL_TRAP
	bcs	err
	nop
	sethi	%hi (ASM_PRIVATE_SYMBOL (curbrk)),%o3
	st	%o2,[%o3+%lo (ASM_PRIVATE_SYMBOL (curbrk))]
	retl
	mov	%g0,%o0

err:
#ifdef REENT
	sethi	%hi (ASM_PRIVATE_SYMBOL (cerror_r)),%g1
	or	%g1,%lo (ASM_PRIVATE_SYMBOL (cerror_r)),%g1
#else
	sethi	%hi (ASM_PRIVATE_SYMBOL (cerror)),%g1
	or	%g1,%lo (ASM_PRIVATE_SYMBOL (cerror)),%g1
#endif
	jmpl	%g1,%g0
	mov	%o5,%o1
