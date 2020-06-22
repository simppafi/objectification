using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Entities;

namespace simppafi
{
	public class SceneCameraAnimation : simppafi.BaseSceneCamera
	{
		private float 			duration;
		public float3 			camFrom;
		public float3 			camTo;
		private float3 			lookatFrom;
		private float3 			lookatTo;
		private float 			fovFrom;
		private float 			fovTo;

		private float 			startFadeFrom;
		private float 			startFadeTo;
		private float 			endFadeFrom;
		private float 			endFadeTo;
		private float 			fadeInDuration;
		private float 			fadeOutDuration;

		private float 			bokehInNear;
		private float 			bokehOutNear;
		private float 			bokehInFar;
		private float 			bokehOutFar;

		public SceneCameraAnimation(	Frustum CameraFrustum, Transform3D CameraTransform,
										int scenePosition, float duration, 
										float3 camFrom, float3 camTo,
										float3 lookatFrom, float3 lookatTo,
										float fovFrom, float fovTo,
										float startFadeFrom = 0, float startFadeTo = 0,
										float endFadeFrom = 0, float endFadeTo = 0,
										float fadeInDuration = 1f, float fadeOutDuration = 1f,
										float bokehInNear = .025f, float bokehOutNear = .025f,
										float bokehInFar = .2f, float bokehOutFar = .2f
										)
		{
			base.CameraFrustum = CameraFrustum;
			base.CameraTransform = CameraTransform;
			base.scenePosition = scenePosition;
			
			this.debug_camFrom = camFrom;
			this.debug_camTo = camTo;

			this.duration = duration;
			this.camFrom = camFrom;
			this.camTo = camTo;
			this.lookatFrom = lookatFrom;
			this.lookatTo = lookatTo;
			this.fovFrom = fovFrom;
			this.fovTo = fovTo;
			this.startFadeFrom = startFadeFrom;
			this.startFadeTo = startFadeTo;
			this.endFadeFrom = endFadeFrom;
			this.endFadeTo = endFadeTo;

			this.fadeInDuration = fadeInDuration;
			this.fadeOutDuration = fadeOutDuration;

			this.bokehInNear = bokehInNear;
			this.bokehOutNear = bokehOutNear;
			this.bokehInFar = bokehInFar;
			this.bokehOutFar = bokehOutFar;
		}

		override public void SetEndFades(float endFadeFrom, float endFadeTo, float fadeOutDuration, float duration)
		{
			this.endFadeFrom = endFadeFrom;
			this.endFadeTo = endFadeTo;
			this.fadeOutDuration = fadeOutDuration;
			this.duration = duration;
		}

		private float starttime = 0f;
		override public void Setup(float time)
		{
			starttime = time;

			simppafi.GlobalParams.FadeAddValue = startFadeFrom;
			simppafi.GlobalParams.BokehLimitFar = bokehInFar;
			simppafi.GlobalParams.BokehLimitNear = bokehInNear;
		}
		
		override public void Update(float time, float ftime, float gtime)
		{
			var st = time-starttime;
			var div = st / duration;
			var fadeStartDiv = Math.Min(fadeInDuration, st) / fadeInDuration;
			var fadeEndDiv = Math.Max(0f, st-(duration-fadeOutDuration)) / fadeOutDuration;
			
			if(fadeStartDiv < 1f)
			{
				simppafi.GlobalParams.FadeAddValue = startFadeFrom + (startFadeTo - startFadeFrom) * fadeStartDiv;
			}
			else if(fadeEndDiv > 0f)
			{
				simppafi.GlobalParams.FadeAddValue = endFadeFrom + (endFadeTo - endFadeFrom) * fadeEndDiv;
			}
			else if(fadeStartDiv > .9999f && fadeEndDiv < 0.00001f)
			{
				simppafi.GlobalParams.FadeAddValue = 0f;
			}

			simppafi.GlobalParams.BokehLimitFar = bokehInFar + (bokehOutFar - bokehInFar) * div;
			simppafi.GlobalParams.BokehLimitNear = bokehInNear + (bokehOutNear - bokehInNear) * div;

			var radians = fovFrom + (fovTo - fovFrom) * div;
			var lookat = lookatFrom + (lookatTo - lookatFrom) * div;
			var position = camFrom + (camTo - camFrom) * div;

			CameraFrustum.FovRadians = radians;
			CameraTransform.Position = position;
			//CameraTransform.LookAt(lookat, float3( Math.Cos(gtime*.2657f)*.02f,1,Math.Sin(ftime*.432f)*.02f ));
			
			CameraTransform.LookAt(position+lookat,float3( Math.Cos(gtime*.2657f)*.02f,1,Math.Sin(ftime*.432f)*.02f ));

			simppafi.BaseSceneCamera.CameraDirection = lookat;
			simppafi.BaseSceneCamera.CameraPosition = position;
			
		}

	}
}
