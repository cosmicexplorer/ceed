target triple = "x86_64-unknown-linux-gnu"

@.str = constant [7 x i8] c"hello\0A\00"

define i32 @main() {
  %1 = call i32 (i8*) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str, i32 0, i32 0))
  ret i32 0
}

declare i32 @printf(i8*)
