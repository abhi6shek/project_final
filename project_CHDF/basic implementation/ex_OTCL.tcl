# Add a member function call”greet”
Class Teacher
Teacher instproc init {subject} {
$self instvar subject_
set subject_ $subject
}
# Creating a child class of teacher and student
Teacher instproc greet {} {
$self instvar subject_
puts "$subject_ teacher askwhich subject u studied?"
}
#creating a teacher and student object
Class student -superclass Teacher
student instproc greet {} {
$self instvar subject_
puts "$subject_ say
i studied maths"
}
# calling member function “greet” of each node
set a [new Teacher maths]
set b [new student Jey]
$a greet
$b greet
