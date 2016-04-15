@.str = constant [9 x i8] c"hellooo\0A\00"
@str = global i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str, i32 0, i32 0), align 8

define i32 @main() {
  %1 = load i8*, i8** @str, align 8
  %2 = call i32 (i8*, ...) @printf(i8* %1)
  ret i32 0
}

declare i32 @printf(i8*, ...)
