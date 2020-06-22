using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Entities;

namespace simppafi
{
	public class BaseSceneCamera
	{
		protected Frustum 		CameraFrustum;
		protected Transform3D 	CameraTransform;

		public static float3 CameraDirection = float3(0); 
		public static float3 CameraPosition = float3(0);

		public int scenePosition = 0;

		public float3 			debug_camFrom;
		public float3 			debug_camTo;

		public BaseSceneCamera(	)
		{
			
		}

		public virtual void Setup(float time) {}
		public virtual void Update(float time, float ftime, float gtime) {}
		public virtual void PointerPressed(object sender, Fuse.Input.PointerPressedArgs args){}
		public virtual void PointerReleased(object sender, Fuse.Input.PointerReleasedArgs args){}
		public virtual void PointerMoved(object sender, Fuse.Input.PointerMovedArgs args){}
		public virtual void PointerWheelMoved(object sender, Fuse.Input.PointerWheelMovedArgs args){}
		public virtual void KeyPressed(object sender, Fuse.Input.KeyPressedArgs args){}
		public virtual void KeyReleased(object sender, Fuse.Input.KeyReleasedArgs args){}
		
		public virtual void SetEndFades(float endFadeFrom, float endFadeTo, float fadeOutDuration, float duration){}

		public virtual void StartValues() {}
		public virtual string GetValues() {return "notset";}
		
	}
}
