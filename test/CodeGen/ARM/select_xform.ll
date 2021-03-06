; RUN: llc < %s -mtriple=arm-apple-darwin -mcpu=cortex-a8 | FileCheck %s -check-prefix=ARM
; RUN: llc < %s -mtriple=thumb-apple-darwin -mcpu=cortex-a8 | FileCheck %s -check-prefix=T2
; rdar://8662825

define i32 @t1(i32 %a, i32 %b, i32 %c) nounwind {
; ARM: t1:
; ARM: sub r0, r1, #-2147483647
; ARM: movgt r0, r1

; T2: t1:
; T2: mvn r0, #-2147483648
; T2: add r0, r1
; T2: movgt r0, r1
  %tmp1 = icmp sgt i32 %c, 10
  %tmp2 = select i1 %tmp1, i32 0, i32 2147483647
  %tmp3 = add i32 %tmp2, %b
  ret i32 %tmp3
}

define i32 @t2(i32 %a, i32 %b, i32 %c, i32 %d) nounwind {
; ARM: t2:
; ARM: sub r0, r1, #10
; ARM: movgt r0, r1

; T2: t2:
; T2: sub.w r0, r1, #10
; T2: movgt r0, r1
  %tmp1 = icmp sgt i32 %c, 10
  %tmp2 = select i1 %tmp1, i32 0, i32 10
  %tmp3 = sub i32 %b, %tmp2
  ret i32 %tmp3
}

define i32 @t3(i32 %a, i32 %b, i32 %x, i32 %y) nounwind {
; ARM: t3:
; ARM: mvnlt r2, #0
; ARM: and r0, r2, r3

; T2: t3:
; T2: movlt.w r2, #-1
; T2: and.w r0, r2, r3
  %cond = icmp slt i32 %a, %b
  %z = select i1 %cond, i32 -1, i32 %x
  %s = and i32 %z, %y
 ret i32 %s
}

define i32 @t4(i32 %a, i32 %b, i32 %x, i32 %y) nounwind {
; ARM: t4:
; ARM: movlt r2, #0
; ARM: orr r0, r2, r3

; T2: t4:
; T2: movlt r2, #0
; T2: orr.w r0, r2, r3
  %cond = icmp slt i32 %a, %b
  %z = select i1 %cond, i32 0, i32 %x
  %s = or i32 %z, %y
 ret i32 %s
}

define i32 @t5(i32 %a, i32 %b, i32 %c) nounwind {
entry:
; ARM: t5:
; ARM-NOT: moveq
; ARM: orreq r2, r2, #1

; T2: t5:
; T2-NOT: moveq
; T2: orreq r2, r2, #1
  %tmp1 = icmp eq i32 %a, %b
  %tmp2 = zext i1 %tmp1 to i32
  %tmp3 = or i32 %tmp2, %c
  ret i32 %tmp3
}

define i32 @t6(i32 %a, i32 %b, i32 %c, i32 %d) nounwind {
; ARM: t6:
; ARM-NOT: movge
; ARM: eorlt r3, r3, r2

; T2: t6:
; T2-NOT: movge
; T2: eorlt.w r3, r3, r2
  %cond = icmp slt i32 %a, %b
  %tmp1 = select i1 %cond, i32 %c, i32 0
  %tmp2 = xor i32 %tmp1, %d
  ret i32 %tmp2
}

define i32 @t7(i32 %a, i32 %b, i32 %c) nounwind {
entry:
; ARM: t7:
; ARM-NOT: lsleq
; ARM: andeq r2, r2, r2, lsl #1

; T2: t7:
; T2-NOT: lsleq.w
; T2: andeq.w r2, r2, r2, lsl #1
  %tmp1 = shl i32 %c, 1
  %cond = icmp eq i32 %a, %b
  %tmp2 = select i1 %cond, i32 %tmp1, i32 -1
  %tmp3 = and i32 %c, %tmp2
  ret i32 %tmp3
}

