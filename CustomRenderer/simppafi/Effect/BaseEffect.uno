namespace simppafi.Effect
{
	public class BaseEffect
	{
		public bool SkipPost = false;
		public bool AddToOtherEffects = true;
		public bool SkipMask = false;
		
		protected void init()
		{
			PostFramebuffer = new framebuffer(int2(8,8), Uno.Graphics.Format.RGBA8888, Uno.Graphics.FramebufferFlags.DepthBuffer);
		}

		private float 				_maskColor;
		public float 				MaskColor
		{
			get{return _maskColor;}
			set{
				_maskColor = value;
				postBackground.MaskColor = value;
				postFront.MaskColor = value;
				finalBackground.MaskColor = value;
				finalFront.MaskColor = value;
			}
		}

		public simppafi.BasePost	Post;
		public framebuffer 			PostTarget = new framebuffer(int2(8,8), Uno.Graphics.Format.RGBA8888, Uno.Graphics.FramebufferFlags.DepthBuffer);

		private framebuffer 		_postFramebuffer;
		public framebuffer 			PostFramebuffer
		{
			get{return _postFramebuffer;}
			set{
				_postFramebuffer = value;
				postBackground.PostFramebuffer = value;
				postFront.PostFramebuffer = value;
				finalBackground.PostFramebuffer = value;
				finalFront.PostFramebuffer = value;
			}
		}

		public simppafi.BasePass 	postBackground = new DefaultPostBgPass();
		public simppafi.BasePass 	postFront = new DefaultPostFrontPass();
		public simppafi.BasePass 	finalBackground;
		public simppafi.BasePass 	finalFront;
	}
}
