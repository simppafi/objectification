namespace simppafi
{
	public class MirrorPass : BasePass
	{
		//float3 CameraPosition : EnvMirror.Position;

		//float4x4 WorldView : EnvMirror.mirrorMatrix;

		//float Depth:
		//	req(WorldPosition as float3)
		//		(Uno.Vector.Length(pixel WorldPosition - EnvMirror.Position) / EnvMirror.Depth);

		//PixelColor : float4(Depth,Depth,Depth,1);//simppafi.Utils.BufferPacker.PackFloat16(Depth), 0,0);
		
		

		ClipPosition:
			req(WorldPosition as float3)
				Uno.Vector.Transform(float4(WorldPosition,1), EnvMirror.mirrorMatrix);

		//PixelColor : prev;
	}
}