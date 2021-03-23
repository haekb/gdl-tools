extends Node

class Anim:
	var skeleton_count = 0
	var version = 0
	var skeleton_data_pointer = 0
	var effect_count = 0
	var effect_pointer = 0
	var psys_count = 0
	var psys_pointer = 0
	
	# Scratch space
	var current_animation_position = 0
	var current_animation_data = null
	var current_skeleton_position = 0
	var current_skeleton = null
	
	# Processed data
	var skeletons = []
	
	func read(f : File):
		self.skeleton_count = f.get_16()
		self.version = f.get_16()
		self.skeleton_data_pointer = f.get_32()
		self.effect_count = f.get_32()
		self.effect_pointer = f.get_32()
		
		# World data?
		if self.version != 0:
			self.psys_count = f.get_32()
			self.psys_pointer = f.get_32()
		# End If
		
		for _i in range(self.skeleton_count):
			var skeleton = Skel.new()
			skeleton.read(self, f)
			self.skeletons.append(skeleton)
		# End For
		
		for skeleton in self.skeletons:
			skeleton.read_data(self, f)
		# End For
		return Helpers.make_response(Helpers.IMPORT_RETURN.SUCCESS)
	# End Func
	
	func anim_seek(pointer, f : File):
		f.seek(self.current_animation_position + pointer)
	# End Func
	
	func skel_seek(pointer, f : File):
		f.seek(self.current_skeleton_position + pointer)
	# End Func
	
	class Skel:
		var name = ""
		var data_pointer = 0
		
		var data = null
		
		func read(_anim : Anim, f : File):
			# Read it like this because sometimes there's junk after the null
			self.name = Helpers.read_c_string(f)
			Helpers.seek_ahead(31 - len(self.name), f)
			
			self.data_pointer = f.get_32()
		# End Func
		
		func read_data(_anim : Anim, f : File):
			f.seek(self.data_pointer)
			_anim.current_skeleton_position = f.get_position()
			
			self.data = _anim.SkelData.new()
			self.data.read(_anim, f)
		# End Func
		
	# End Class
	
	class SkelData:
		var header_pointer = 0
		var data_pointer = 0 # Skeletal Animation
		var obj_data_pointer = 0 # Vertex Animation
		var bone_pointer = 0
		var bone_count = 0
		var animation_count = 0
		var name = ""
		
		var bones = []
		
		var animation_data = null
		var animation_headers = []
		var animations = []
		
		func read(_anim : Anim, f : File):
			self.header_pointer = f.get_32()
			# Skeletal Anim
			self.data_pointer = f.get_32()
			# Vertex Anim
			self.obj_data_pointer = f.get_32()
			self.bone_pointer = f.get_32()
			self.bone_count = f.get_32()
			self.animation_count = f.get_32()
			
			self.name = Helpers.read_c_string(f)
			Helpers.seek_ahead(31 - len(self.name), f)
			
			_anim.current_skeleton = self
			
			_anim.skel_seek(self.data_pointer, f)
			
			self.animation_data = _anim.AnimData.new()
			self.animation_data.read(_anim, f)
			
			_anim.skel_seek(self.header_pointer, f)
			for _i in range(self.animation_count):
				var header = _anim.AnimHeader.new()
				header.read(_anim, f)
				self.animation_headers.append(header)
			# End For
			
			_anim.skel_seek(self.bone_pointer, f)
			for bi in range(self.bone_count):
				var bone = _anim.SkelBone.new()
				bone.read(_anim, f)
				self.bones.append(bone)
				
				var bone_position = f.get_position() 
				
				self.animations.append([])
				
				_anim.anim_seek(bone.sequence_pointer, f)
				
				for i in range(_anim.current_animation_data.sequence_count):
					# Only first one for now...
					#if i > 0:
					#	continue
					# End If	
					
					var sequence = _anim.AnimSequence.new()
					sequence.read(_anim, i, f)
					self.animations[bi].append(sequence)
				# End For
				
				# Reset position
				f.seek(bone_position)
			# End For
		# End Func

	class SkelBone:
		var name = ""
		var location = Vector3()
		var type = Constants.Bone_Types.EMPTY
		var flags = 0
		var mb_flags = 0
		var sequence_pointer = 0
		var parent_id = -1
		
		# Linkage
		var id = -1
		var parent = null
		var children = []
		var child_count = 0
		
		# Transform
		var bind_matrix = Basis()
		
		func read(_anim : Anim, f : File):
			self.name = Helpers.read_c_string(f)
			Helpers.seek_ahead(31 - len(self.name), f)
			
			self.location = Helpers.read_vector3(f)
			self.type = f.get_16()
			self.flags = f.get_16()
			self.mb_flags = f.get_32()
			self.sequence_pointer = f.get_32()
			self.parent_id = Helpers.utsi(f.get_32())
			
			# Setup a default bind pose
			self.bind_matrix = Transform(Basis(), self.location)
		# End Func
		
	class AnimData:
		var compress_ang_pointer = 0
		var compress_pos_pointer = 0
		var compress_unit_pointer = 0
		var block_pointer = 0
		var sequence_pointer = 0
		var sequence_count = 0 # Animations
		var object_count = 0 # Bones
		
		# Arrays of 256 items, if an animation is compressed it'll contain an index to either of these
		var compress_ang = []
		var compress_pos = []
		var compress_unit = []
		
		func read(_anim : Anim, f : File):
			_anim.current_animation_position = f.get_position()
			_anim.current_animation_data = self
			
			self.compress_ang_pointer = f.get_32()
			self.compress_pos_pointer = f.get_32()
			self.compress_unit_pointer = f.get_32()
			self.block_pointer = f.get_32()
			self.sequence_pointer = f.get_32()
			self.sequence_count = f.get_32()
			self.object_count = f.get_32()
			
			if self.compress_ang_pointer > 0:
				_anim.anim_seek(self.compress_ang_pointer, f)
				for _i in range(256):
					self.compress_ang.append(f.get_float())
			# End If
			
			if self.compress_pos_pointer > 0:
				_anim.anim_seek(self.compress_pos_pointer, f)
				for _i in range(256):
					self.compress_pos.append(f.get_float())# * 0.008)
			# End If
			
			if self.compress_unit_pointer > 0:
				_anim.anim_seek(self.compress_unit_pointer, f)
				for _i in range(256):
					self.compress_unit.append(f.get_float())
			# End If
		# End Class
		
	class AnimHeader:
		var name = ""
		var frame_count = 0
		var frame_rate = 0
		var loop = 0
		var fix_pos = 0 # Might a bool?
		var effect_count = 0
		var flags = 0
		var effect_pointer = -1
		
		func read(_anim : Anim, f : File):
			self.name = Helpers.read_c_string(f)
			Helpers.seek_ahead(31 - len(self.name), f)
			
			self.frame_count = f.get_16()
			self.frame_rate = f.get_16()
			self.loop = bool(f.get_16())
			self.fix_pos = f.get_16()
			self.effect_count = f.get_16()
			self.flags = f.get_16()
			self.effect_pointer = f.get_32()
			
			# TODO: Effects!
			
		# End Func
	# End Class
	
	class AnimSequence:
		var type = 0
		var size = 0
		var data_pointer = 0
		
		# Processed
		var data = []
		var transforms = []
		
		var locations = []
		var rotations = []
		var scales = []
		
		func read(_anim : Anim, index, f : File):
			self.type = f.get_16()
			self.size = f.get_16()
			self.data_pointer = f.get_32()
			
			var sequence_pointer = f.get_position()
			var anim_data = _anim.current_animation_data
			
			_anim.anim_seek(self.data_pointer + _anim.current_animation_data.block_pointer, f)
			
			var debug_ftell = f.get_position()
			
			# Decompiled code, this will skip past the useless header in the block data
			var jump_spot = (_anim.current_skeleton.animation_headers[index].frame_count + 0x1f >> 5) * 4
			
			Helpers.seek_ahead( jump_spot, f )
			
			var total_size = self.size + _anim.current_skeleton.animation_headers[index].frame_count
			
			# Fill in some blanks
			for _i in range(_anim.current_skeleton.animation_headers[index].frame_count):
				locations.append(Vector3())
				rotations.append(Vector3())
				scales.append(Vector3(1, 1, 1))
			
			var is_compressed = type & 0x2000 != 0
			
			if self.size == 0:
				# For now hop back
				f.seek(sequence_pointer)
				return
			
			var current_type = type
			for i in range(_anim.current_skeleton.animation_headers[index].frame_count):
				var rotation = rotations[i]
				var location = locations[i]
				var scale = scales[i]
				
				if is_compressed:
					if current_type & 0x1:
						var rot_index = Helpers.utsb(f.get_8())
						rotation.x = anim_data.compress_ang[rot_index]
					if current_type & 0x2:
						var rot_index = Helpers.utsb(f.get_8())
						rotation.y = anim_data.compress_ang[rot_index]
					if current_type & 0x4:
						var rot_index = Helpers.utsb(f.get_8())
						rotation.z = anim_data.compress_ang[rot_index]
					if current_type & 0x10:
						var loc_index = Helpers.utsb(f.get_8())
						location.x = anim_data.compress_pos[loc_index]
					if current_type & 0x20:
						var loc_index = Helpers.utsb(f.get_8())
						location.y = anim_data.compress_pos[loc_index]
					if current_type & 0x40:
						var loc_index = Helpers.utsb(f.get_8())
						location.z = anim_data.compress_pos[loc_index]
					if current_type & 0x100:
						scale.x = Helpers.utsb(f.get_8()) / 256.0
					if current_type & 0x200:
						scale.y = Helpers.utsb(f.get_8()) / 256.0
					if current_type & 0x400:
						scale.z = Helpers.utsb(f.get_8()) / 256.0
				
				
#				# Rotation data
#				if is_compressed and i != 0:
#					if current_type & 0x1:
#						rotation.x = Helpers.utsb(f.get_8()) / 256.0
#					if current_type & 0x2:
#						rotation.y = Helpers.utsb(f.get_8()) / 256.0
#					if current_type & 0x4:
#						rotation.z = Helpers.utsb(f.get_8()) / 256.0
#					if current_type & 0x10:
#						location.x = Helpers.utsb(f.get_8()) / 256.0
#					if current_type & 0x20:
#						location.y = Helpers.utsb(f.get_8()) / 256.0
#					if current_type & 0x40:
#						location.z = Helpers.utsb(f.get_8()) / 256.0
#					if current_type & 0x100:
#						scale.x = Helpers.utsb(f.get_8()) / 256.0
#					if current_type & 0x200:
#						scale.y = Helpers.utsb(f.get_8()) / 256.0
#					if current_type & 0x400:
#						scale.z = Helpers.utsb(f.get_8()) / 256.0
#				else:
#					if current_type & 0x1:
#						rotation.x = Helpers.utsh(f.get_16()) / 65536.0
#					if current_type & 0x2:
#						rotation.y = Helpers.utsh(f.get_16()) / 65536.0
#					if current_type & 0x4:
#						rotation.z = Helpers.utsh(f.get_16()) / 65536.0
#					if current_type & 0x10:
#						location.x = Helpers.utsh(f.get_16()) / 65536.0
#					if current_type & 0x20:
#						location.y = Helpers.utsh(f.get_16()) / 65536.0
#					if current_type & 0x40:
#						location.z = Helpers.utsh(f.get_16()) / 65536.0
#					if current_type & 0x100:
#						scale.x = Helpers.utsh(f.get_16()) / 65536.0
#					if current_type & 0x200:
#						scale.y = Helpers.utsh(f.get_16()) / 65536.0
#					if current_type & 0x400:
#						scale.z = Helpers.utsh(f.get_16()) / 65536.0
						
#					if current_type & 0x1:
#						rotation.x = f.get_float()
#					if current_type & 0x2:
#						rotation.y = f.get_float()
#					if current_type & 0x4:
#						rotation.z = f.get_float()
#					if current_type & 0x10:
#						location.x = f.get_float()
#					if current_type & 0x20:
#						location.y = f.get_float()
#					if current_type & 0x40:
#						location.z = f.get_float()
#					if current_type & 0x100:
#						scale.x = f.get_float()
#					if current_type & 0x200:
#						scale.y = f.get_float()
#					if current_type & 0x400:
#						scale.z = f.get_float()
					
				rotations[i] = rotation
				locations[i] = location
				scales[i] = scale
				
				#current_type = current_type + self.size * 4
				#break
			
#			for _i in range( total_size ):
#				self.data.append( f.get_float() )
#			# End For
#			for _i in range( total_size ):
#				if size == 3:
#					var x = Helpers.utsb(f.get_8())
#					var y = Helpers.utsb(f.get_8())
#					var z = Helpers.utsb(f.get_8())
#					x = float(x) / 256.0
#					y = float(x) / 256.0
#					z = float(x) / 256.0
#					self.data.append( Vector3(x, y, z) )
#				elif size == 6:
#					var x = Helpers.utsh(f.get_16())
#					var y = Helpers.utsh(f.get_16())
#					var z = Helpers.utsh(f.get_16())
#					x = float(x) / 65536.0
#					y = float(x) / 65536.0
#					z = float(x) / 65536.0
#					self.data.append( Vector3(x, y, z) )
#				elif size == 1:
#					var xyz = Helpers.utsb(f.get_8())
#					xyz = float(xyz) / 256.0
#					self.data.append( Vector3(xyz, xyz, xyz) )
					
			
#			# For now read as a vector!
#			var to_vec = []
#			var vec = Vector3()
#
#			for i in range( len(self.data) ):
#				to_vec.append(self.data[i])
#
#				if len(to_vec) == 3:
#					self.transforms.append( Vector3(to_vec[0], to_vec[1], to_vec[2]) )
#					to_vec = []
#				# End If
#			# End For
			
			# For now hop back
			f.seek(sequence_pointer)
		# End Func
	# End Class
