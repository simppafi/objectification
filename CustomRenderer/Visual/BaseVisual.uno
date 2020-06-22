using Fuse.Entities.Designer;

namespace simppafi
{
	public abstract class BaseVisual
	{
		public simppafi.Effect.BaseEffect 	Effect = new Effect.EffectNone();

		protected Fuse.DrawContext			_dc;

		public float2 						UVCoord = float2(0,0);
		private int _uvCoordID = 0;
		public int UVCoordID {
			get {return _uvCoordID;}
			set {
						if(value == 0) {
					UVCoord = float2(0f,0f);
				} else 	if(value == 1) {
					UVCoord = float2(0.5f,0f);
				} else 	if(value == 2) {
					UVCoord = float2(0f,.5f);
				} else 	if(value == 3) {
					UVCoord = float2(0.5f,0.5f);
				}
			}
		}

		public float2 						ReflectionCoord = float2(0,0);
		private int _reflCoordID = 0;
		public int ReflectionCoordID {
			get {return _reflCoordID;}
			set {
						if(value == 0) {
					ReflectionCoord = float2(0f,0f);
				} else 	if(value == 1) {
					ReflectionCoord = float2(0.5f,0f);
				} else 	if(value == 2) {
					ReflectionCoord = float2(0f,.5f);
				} else 	if(value == 3) {
					ReflectionCoord = float2(0.5f,0.5f);
				}
			}
		}

		public bool 						Disabled = false;
		private bool 						_isSetup = false;
		public bool							SkipUVDraw = false;
		public bool							SkipReflectDraw = false;
		public bool							SkipDepthDraw = false;
		public bool							SkipNormalDraw = false;
		public bool 						SkipMaskDraw = false;
		public bool 						SkipSSAO = false;
		public bool							CastShadow = true;
		public bool 						AddShadow = true;
		public bool 						IsMirror = false;
		public bool 						DrawSSR = false;
		public bool 						IsSilhuette = false;

		public bool isSetup {
			get {return _isSetup;}
		}

		public virtual void Setup() {this._isSetup = true; simppafi.Utils.CachedRandom.Initialize(1);}
		public virtual void OnOff() {}
		public virtual void Settings() {}
		public virtual void OnUpdate() {}
		public virtual void DrawParticles(Fuse.DrawContext dc) {}
		public virtual void DrawSecond(Fuse.DrawContext dc) {}
		public virtual void Draw(Fuse.DrawContext dc)
		{
			_dc = dc;
			OnDraw(dc);
		}
		protected abstract void OnDraw(Fuse.DrawContext dc);
		public virtual void DrawSilhuette(Fuse.DrawContext dc){}

		public virtual void Reset() {}
		public virtual void Hit(float val) {}
		public virtual void Peak(float power) {}
		public virtual void Change(float val) {}

		public float MoveTime = 0f;

	}
}