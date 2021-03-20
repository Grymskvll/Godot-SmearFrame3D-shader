![Video demo](https://user-images.githubusercontent.com/17933607/111867517-c5a3f380-8974-11eb-930a-1dd42f1c0e72.mp4)



# Disclaimer
At the time of writing, Godot does not have a reasonable way to add shader effects to meshes/materials. The process of adding this smear effect to an existing material is tedious and likely destructive. Use in production at your own peril.

Simple Free-Look Camera (used in the demo) is by Adam Viola: https://github.com/adamviola/simple-free-look-camera

# Usage
## Adding smear
1. Go here and give this issue a thumbs up: https://github.com/godotengine/godot-proposals/issues/1779
	1. Cry because Godot doesn't have a practical way to add shader effects to existing materials
1. To proceed, your mesh must use a *ShaderMaterial* with a (text) *Shader*:
	* If your mesh uses a *SpatialMaterial*, convert it to a (text) *ShaderMaterial*
	* If your mesh uses a *VisualShader*, convert it to a (text) *Shader*
	* **Warning: There's no way to convert it back!**
	* Tip: if you're going to instance the mesh (or it's parent) multiple times, turn on *Local To Scene* for the material
1. Copy the contents of *SmearFrame3D.shader* into the generated shader:
	* `uniform`s at the top 
	* Replace (or merge with) the `vertex` function
	* Keep things in the same order
1. Add a SmearFrame3D node as a child of your MeshInstance
1. Configure the SmearFrame3D node (see below)

## Configuring smear
Next, you can tune the smear (select the SmearFrame3D node):
* *Enabled*: toggle smear on/off
* *Smear Amount*: overall smear length (`Smear Amount: 1`: vertices will at most move back to their position on previous frame (unless there's noise))
* *Front Smear Factor*: how much smear to add *ahead* of motion
* *Rear Smear Factor*: how much smear to add *behind* motion
* *Front Normal Bias*: front-facing normals are better aligned with our motion (prevents pinching especially with low noise)
* *Rear Normal Bias*: rear-facing normals are better aligned against our motion (prevents pinching especially with low noise)
* *Noise Factor*: how much noise to add to smear
* *Noise Max*: how far the noise spikes extend from the mesh
* *Noise Min*: how far the noise spikes extend into the mesh
* *Tuned To Fps*: the framerate that the smear is tuned to (for consistent smear regardless of fps)
* *Smear Speed Min*: the minimum speed (actually distance travelled since last frame) before smear appears
* *Smear Speed Ease*: the additional speed (actually additional distance travelled since last frame) before smear reaches maximum length
* *Noise Tex Width*: width of the noise texture
* *Noise Tex Height*: height of the noise texture

