extends Node

'''TUYỆT ĐỐI KHÔNG ĐƯỢC XÓA NODE NÀY

----Đây là node trung gian cho các item trong inventory---
----để chúng có thể gọi hàm đợi do trong godot node-------
----Resource không phải là một node nên chúng không có---- 
----trong scene tree, do đó cần một node trung gian làm---
--------------------------TIMER---------------------------'''

@onready var timer = Timer.new()
