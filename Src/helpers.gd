extends Node

#
# Helpers
# 
enum IMPORT_RETURN{SUCCESS, ERROR}
func make_response(code, message = ''):
	return { 'code': code, 'message': message }
# End Func
