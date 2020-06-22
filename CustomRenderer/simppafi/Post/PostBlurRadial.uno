using Uno;
using Fuse;
using Uno.Vector;
using Uno.Math;
using Fuse.Drawing.Primitives;

namespace simppafi
{
	public class PostBlurRadial : BasePost
	{
		public float Zoom {get;set;}
        public float Blend {get;set;}
        public int Passes {get;set;}
        public float Resolution {get;set;}
        public float Brightness {get;set;}

        public float2 Center = float2(0,0);
        public float CenterX{ get{return Center.X;} set{Center.X = value;}}
        public float CenterY{ get{return Center.Y;} set{Center.Y = value;}}

		private int2 						size;

		private framebuffer					fb0_h;
		private framebuffer					fb1_h;

		public PostBlurRadial()
		{
			// not too silly default values
            // but playing with them is the whole point :)
            Zoom = .9887f;//9887f;//.9927f;
            Blend = .96f;
            Passes = 4;
            Resolution = .5f;
            Brightness = 1.2f;
            Center.X = .0f;//.2f;
            Center.Y = .0f;//-.3f;
		}

		float ResolutionOld = 0;
		override public void Process(Fuse.DrawContext dc, framebuffer source, framebuffer target)
		{

			int hiresPasses = 2;        // number of passes before quartering the resolution
            int2 fbSize = dc.GLViewportPixelSize;
            fbSize.X = (int) (fbSize.X * Resolution);
            fbSize.Y = (int) (fbSize.Y * Resolution);


            if( defined(Debug) && Resolution!=ResolutionOld)
            {
                ResolutionOld = Resolution;
                //debug_log "Resolution scale: " + Resolution + " = hires target: " + fbSize;
                //debug_log "texels read / viewport size: " + (hiresPasses*4*Resolution + (Passes-hiresPasses)*4*Resolution*.5f).ToString();
            }

            var fb0 = FramebufferPool.Lock( fbSize, Uno.Graphics.Format.RGBA8888, true );
            var fb1 = FramebufferPool.Lock( fbSize, Uno.Graphics.Format.RGBA8888, false );
            var fb0_h = FramebufferPool.Lock( fbSize/2, Uno.Graphics.Format.RGBA8888, false );
            var fb1_h = FramebufferPool.Lock( fbSize/2, Uno.Graphics.Format.RGBA8888, false );

            dc.PushRenderTarget(fb0);
            dc.Clear(float4(0,0,0,1),1);    // hardcoded clear values for now

			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
				PixelColor : sample(source.ColorBuffer, ClipPosition.XY * 0.5f + 0.5f, samplerState);
			};

            dc.PopRenderTarget();

            var blurFrame = FramebufferPool.Lock( fbSize/3, Uno.Graphics.Format.RGBA8888, false );
            dc.PushRenderTarget(blurFrame);
            dc.Clear(float4(0,0,0,1),1);    // hardcoded clear values for now
            draw Quad
            {
                DepthTestEnabled: false;
                CullFace: Uno.Graphics.PolygonFace.None;
                PixelColor : sample(source.ColorBuffer, ClipPosition.XY * 0.5f + 0.5f, samplerState);
            };
            dc.PopRenderTarget();
            blur(dc, blurFrame, 3);



            var fbsrc = fb0;
            var fbdst = fb1;
            float z = Zoom;
            float c = Blend;
            for(int i = 0; i < Passes; i++)
            {
                float zz = z*z;
                float cc = c*c;
                float norml = (1 - c) / (1 - cc*cc);
                dc.PushRenderTarget(fbdst);
                draw Quad
                {
                    DepthTestEnabled: false;
                    float2 center: Center;
                    float2 tc: 2f*TexCoord - 1f;
                    tc: prev*float2(1,-1) - center;

                    float2 tc0: (( tc * 1) + 1f + center) * .5f;
                    float2 tc1: (( tc * z) + 1f + center) * .5f;
                    float2 tc2: (( tc * (zz)) + 1f + center) * .5f;
                    float2 tc3: (( tc * (zz*z)) + 1f + center) * .5f;
                    float4 px0: sample( fbsrc.ColorBuffer, tc0 );
                    float4 px1: sample( fbsrc.ColorBuffer, tc1 );
                    float4 px2: sample( fbsrc.ColorBuffer, tc2 );
                    float4 px3: sample( fbsrc.ColorBuffer, tc3 );
                    PixelColor: norml*px0 + c*norml*px1 + cc*norml*px2 + c*cc*norml*px3;
                };
                dc.PopRenderTarget();
                z = zz*zz;
                c = cc*cc;

                var tmp = fbsrc;
                fbsrc = fbdst;
                //reduce FB size after the initial high(est)-res passes
                if( i > (hiresPasses-1) ) tmp = ((i&1) == 0) ? fb0_h : fb1_h;
                fbdst = tmp;
            }

           dc.PushRenderTarget(target);
			dc.Clear(float4(0,0,0,0), 1.0f);
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: Uno.Graphics.PolygonFace.None;
                float2 uv : ((TexCoord - .5f) * float2(1,-1))+.5f;
				PixelColor : Brightness*sample( fbsrc.ColorBuffer, uv, samplerState) + sample(blurFrame.ColorBuffer, uv);
			};
			dc.PopRenderTarget();


            FramebufferPool.Release(fb0);
            FramebufferPool.Release(fb1);
            FramebufferPool.Release(fb0_h);
            FramebufferPool.Release(fb1_h);
            FramebufferPool.Release(blurFrame);

		}

        private void blur(DrawContext dc, framebuffer source, int Steps = 1)
        {
            var offset = Fuse.FramebufferPool.Lock(source.Size, source.Format, false);

            // GAUSSIAN DOF
            var offsetX = float2(1f/(float)source.Size.X, 0);
            var offsetY = float2(0, 1f/(float)source.Size.Y);
            for(var i = 0; i < Steps; i++)
            {
                dc.PushRenderTarget(offset);
                dc.Clear(float4(0,0,0,0), 1);
                draw Fuse.Drawing.Primitives.Quad
                {
                    DepthTestEnabled: false;
                    CullFace: Uno.Graphics.PolygonFace.None;
                    float2 uv : ClipPosition.XY * 0.5f + 0.5f;

                    float4 sum : sample(source.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) * 0.204164f;
                    sum : prev + sample(source.ColorBuffer, uv + offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f;
                    sum : prev + sample(source.ColorBuffer, uv - offsetX * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f;
                    sum : prev + sample(source.ColorBuffer, uv + offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f;
                    PixelColor : sum + sample(source.ColorBuffer, uv - offsetX * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f;
                };
                dc.PopRenderTarget();

                dc.PushRenderTarget(source);
                dc.Clear(float4(0,0,0,0), 1);
                draw Fuse.Drawing.Primitives.Quad
                {
                    DepthTestEnabled: false;
                    CullFace: Uno.Graphics.PolygonFace.None;
                    float2 uv : ClipPosition.XY * 0.5f + 0.5f;

                    float4 sum : sample(offset.ColorBuffer, uv, Uno.Graphics.SamplerState.LinearWrap) * 0.204164f;
                    sum : prev + sample(offset.ColorBuffer, uv + offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f;
                    sum : prev + sample(offset.ColorBuffer, uv - offsetY * 1.407333f, Uno.Graphics.SamplerState.LinearWrap) * 0.304005f;
                    sum : prev + sample(offset.ColorBuffer, uv + offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f;
                    PixelColor : sum + sample(offset.ColorBuffer, uv - offsetY * 3.294215f, Uno.Graphics.SamplerState.LinearWrap) * 0.093913f;
                };
                dc.PopRenderTarget();

            }

            Fuse.FramebufferPool.Release(offset);
        }



	}
}