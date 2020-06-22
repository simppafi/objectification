using Uno;
using Uno.Collections;
using Fuse;

namespace simppafi.Color
{
	public static class ColorHexToRGB
	{
		public static float3 HexToRGB(int hex)
	    {
	        float r = (hex & 0xFF0000) >> 16;
	        float g = (hex & 0x00FF00) >> 8;
	        float b = (hex & 0x0000FF);
	        return float3(r/255.0f, g/255.0f, b/255.0f);
	    }

		public static float4 HexToRGBA(int hex, float alpha = 1f)
	    {
	        float r = (hex & 0xFF0000) >> 16;
	        float g = (hex & 0x00FF00) >> 8;
	        float b = (hex & 0x0000FF);
	        return float4(r/255.0f, g/255.0f, b/255.0f, alpha);
	    }
	}
}
