using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Entities;

namespace simppafi
{
	public class SceneCameraDirector : simppafi.BaseSceneCamera
	{

		

		public SceneCameraDirector(	Frustum CameraFrustum, Transform3D CameraTransform)
		{
			base.CameraFrustum = CameraFrustum;
			base.CameraTransform = CameraTransform;
		}

		override public void Setup(float time)
		{
			CameraFrustum.FovRadians = 0.8971977f;
			_position = position = float3(0,10f,100f);

			CamRotX = -3f;
			CamRotY = 0f;
			lookat.X = Math.Sin(CamRotX) * Math.Cos(CamRotY);
    		lookat.Y = Math.Sin(CamRotY);
    		lookat.Z = Math.Cos(CamRotX) * Math.Cos(CamRotY);
		}
		
		override public void Update(float time, float ftime, float gtime)
		{	
			var ease = (float)Fuse.Time.FrameInterval * 30f;
			var ease2 = (float)Fuse.Time.FrameInterval;
			
			ease = (ease > .8f) ? .8f : ease;
			ease2 = (ease2 > .3f) ? .3f : ease2;
			
			if(w_down||s_down||a_down||d_down) {
				movespeed = movespeed + (10f - movespeed) * ease2;
			}else{
				movespeed = 0f;
			}
			if(w_down){position += lookat*movespeed;}
			if(s_down){position -= lookat*movespeed;}
			if(a_down){var rot1 = Vector.Rotate(lookat.XZ, Math.PIf/2f);position -= float3(rot1.X,0,rot1.Y) * movespeed;}
			if(d_down){var rot2 = Vector.Rotate(lookat.XZ, Math.PIf/2f);position += float3(rot2.X,0,rot2.Y) * movespeed;}

			//_lookat = float3(0,10f,0);//
			_lookat = _lookat + (lookat - _lookat) * ease;
			_position = _position + (position - _position) * ease;

			//var angle = -time * .1f;
			//_position = float3(125f * Math.Sin(angle), _position.Y, 125f * Math.Cos(angle));

			CameraTransform.Position = _position;
			CameraTransform.LookAt(_position+_lookat, float3( 0f,1,0f ));
			//CameraTransform.LookAt(_lookat, float3( 0f,1,0f ));

			simppafi.BaseSceneCamera.CameraDirection = _lookat;
			simppafi.BaseSceneCamera.CameraPosition = _position;


		}

		private bool w_down = false;
		private bool s_down = false;
		private bool a_down = false;
		private bool d_down = false;

		private float movespeed = 10f;
		private float3 lookat = float3(0,0,0f);
		private float3 _lookat = float3(0,1,0);
		private float CamRotX = 0f;
		private float CamRotY = 0f;
		private float3 position = float3(0,10f,100f);
		private float3 _position = float3(0,0f,0f);

		private bool PointerIsDown = false;
		private bool PointerIsDrag = false;
		private float2 PointerDelta = float2(0);
		private float2 PointerPrevPoint = float2(0);
		private float PointerReleaseTime = 0f;
		override public void PointerPressed(object sender, Fuse.Input.PointerPressedArgs args)
		{
			PointerPrevPoint = args.WindowPoint;
			PointerIsDown = true;
		}
		override public void PointerReleased(object sender, Fuse.Input.PointerReleasedArgs args)
		{
			PointerIsDown = false;
			if((float)Fuse.Time.FrameTime-PointerReleaseTime < .4f)
			{
				debug_log "doubletap";
				//NextScene();
			}
			PointerReleaseTime = (float)Fuse.Time.FrameTime;
		}
		override public void PointerMoved(object sender, Fuse.Input.PointerMovedArgs args)
		{
			if(PointerIsDown)
			{
				PointerDelta = (args.WindowPoint - PointerPrevPoint);
				PointerPrevPoint = args.WindowPoint;
				CamRotX -= PointerDelta.X * .003f;
				CamRotY -= PointerDelta.Y * .003f;
				lookat.X = Math.Sin(CamRotX) * Math.Cos(CamRotY);
        		lookat.Y = Math.Sin(CamRotY);
        		lookat.Z = Math.Cos(CamRotX) * Math.Cos(CamRotY);
			}
		}
		override public void PointerWheelMoved(object sender, Fuse.Input.PointerWheelMovedArgs args)
		{
			PointerIsDrag = true;
			//var dt = args.WheelDelta.Y > 0f ? 1f : -1f;
			
			CameraFrustum.FovRadians += args.WheelDelta.Y*.01f;//dt * .1f;//args.WheelDelta.Y*.01f;

			debug_log CameraFrustum.FovRadians + " " +BasePass.ZFar + " " +BasePass.ZNear;
			
		}
		
		override public void KeyPressed(object sender, Fuse.Input.KeyPressedArgs args)
		{
			if(args.Key == Uno.Platform.Key.W) {
				w_down = true;
			}
			if(args.Key == Uno.Platform.Key.S) {
				s_down = true;
			}
			if(args.Key == Uno.Platform.Key.A) {
				a_down = true;
			}
			if(args.Key == Uno.Platform.Key.D) {
				d_down = true;
			}
			if(args.Key == Uno.Platform.Key.Up) {
				simppafi.GlobalParams.BokehLimitFar += 0.001f;
			}
			if(args.Key == Uno.Platform.Key.Down) {
				simppafi.GlobalParams.BokehLimitFar -= 0.001f;
			}
			if(args.Key == Uno.Platform.Key.Right) {
				simppafi.GlobalParams.BokehLimitNear += 0.001f;
			}
			if(args.Key == Uno.Platform.Key.Left) {
				simppafi.GlobalParams.BokehLimitNear -= 0.001f;
			}
		}
		override public void KeyReleased(object sender, Fuse.Input.KeyReleasedArgs args)
		{
			if(args.Key == Uno.Platform.Key.W) {
				w_down = false;
			}
			if(args.Key == Uno.Platform.Key.S) {
				s_down = false;
			}
			if(args.Key == Uno.Platform.Key.A) {
				a_down = false;
			}
			if(args.Key == Uno.Platform.Key.D) {
				d_down = false;
			}
		}

		private float3 _start_position = float3(0f);
		private float3 _start_lookat = float3(0f);
		private float _start_fov = 0f;
		private float _start_bokeh_near = 0f;
		private float _start_bokeh_far = 0f;
		override public void StartValues()
		{
			_start_position = _position;
			_start_lookat = _lookat;
			_start_fov = CameraFrustum.FovRadians;
			_start_bokeh_near = simppafi.GlobalParams.BokehLimitNear;
			_start_bokeh_far = simppafi.GlobalParams.BokehLimitFar;
		}

		override public string GetValues()
		{
			var res = "{";
			res += "\"scenePosition\":"+scenePosition+",";
			res += "\"duration\":20,";
			res += "\"canFrom\":{\"x\":"+_start_position.X+",\"y\":"+_start_position.Y+",\"z\":"+_start_position.Z+"},";
			res += "\"camTo\":{\"x\":"+_position.X+",\"y\":"+_position.Y+",\"z\":"+_position.Z+"},";
			res += "\"lookatFrom\":{\"x\":"+_start_lookat.X+",\"y\":"+_start_lookat.Y+",\"z\":"+_start_lookat.Z+"},";
			res += "\"lookatTo\":{\"x\":"+_lookat.X+",\"y\":"+_lookat.Y+",\"z\":"+_lookat.Z+"},";
			res += "\"fovFrom\":"+_start_fov+",";
			res += "\"fovTo\":"+CameraFrustum.FovRadians+",";
			res += "\"startFadeFrom\":"+0f+",";
			res += "\"startFadeTo\":"+0f+",";
			res += "\"endFadeFrom\":"+0f+",";
			res += "\"endFadeTo\":"+0f+",";
			res += "\"fadeInDuration\":"+1f+",";
			res += "\"fadeOutDuration\":"+1f+",";
			res += "\"bokehInNear\":"+_start_bokeh_near+",";
			res += "\"bokehOutNear\":"+simppafi.GlobalParams.BokehLimitNear+",";
			res += "\"bokehInFar\":"+_start_bokeh_far+",";
			res += "\"bokehOutFar\":"+simppafi.GlobalParams.BokehLimitFar;
			
			res += "}";
			return res;
		}


	}
}
