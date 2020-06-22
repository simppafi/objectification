namespace simppafi
{
	public class EdgePass : BasePass
	{
		//float3 Normal : float3(0,1f,0);

		//PixelColor : prev;//float4(0,0,0,1);

		//float3 Normal : 
		//	req(WorldNormal as float3)
		//		WorldNormal;

				/*
		PixelColor: 
			req(Ambient as float3)
			req(Diffuse as float3)
			req(Specular as float3)
				float4(Ambient + Diffuse + Specular, 1f);
				*/

		//float LinearDepth : prev;

		//PixelColor : float4(LinearDepth,LinearDepth,LinearDepth,1f);

		PixelColor : float4(MaskColor,MaskColor,MaskColor,1f);
	}
}