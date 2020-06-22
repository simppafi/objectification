using Uno;
using Uno.Collections;
using Fuse;
using Uno.Graphics;

namespace simppafi
{
	public class ShaderMaterial
	{
		/*
		block Woodframe
		{
    		float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/woodframe/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/woodframe/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/woodframe/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/woodframe/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/woodframe/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
		}
		//*/
///*
		block Floor1
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/floor1/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/floor1/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/floor1/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/floor1/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/floor1/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);	
		}
		//*/
/*
		block Floor2
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/floor2/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/floor2/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/floor2/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/floor2/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/floor2/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);	
		}
*/
		///*
		block Aluminum
		{
    		float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/aluminum/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/aluminum/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/aluminum/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/aluminum/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
		}
		//*/
/*
		block Rough
		{
    		float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/rough/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/rough/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/rough/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/rough/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/rough/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
		}
*/
		
		block Rust4
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/rust4/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/rust4/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/rust4/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/rust4/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/rust4/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
		}


		block Rust1
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/rust/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/rust/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/rust/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/rust/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
		}
		
		/*
		

		block Block
		{
    		float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/block/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/block/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/block/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/block/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/block/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
		}

		
		block Rust2
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/rust2/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/rust2/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/rust2/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/rust2/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);
		}

		block Rust3
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/rust3/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/rust3/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/rust3/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/rust3/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/rust3/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);	
		}
		
		

		
		
		block Greasy
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/greasy/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/greasy/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/greasy/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/greasy/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);	
		}

		block Limestone
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/limestone/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/limestone/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/limestone/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/limestone/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/limestone/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);	
		}
		*/
		/*
		block Granite1
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/granite1/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/granite1/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/granite1/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/granite1/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);	
		}
		*/

		/*
		block Paint
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/paint/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/paint/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/paint/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/paint/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/paint/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);	
		}
//*/

		block Plastic
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/plastic/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/plastic/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/plastic/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/plastic/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/plastic/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);	
		}

		/*block Rubber
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/rubber/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/rubber/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/rubber/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/rubber/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);	
		}*/

		/*block Waterstone
		{
			float2 TexCoord : prev;
			float3 albedo : 						sample(import Texture2D("../../Assets/pbr/waterstone/albedo.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ;
			float metallic : 						sample(import Texture2D("../../Assets/pbr/waterstone/metallic.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float roughness : 						sample(import Texture2D("../../Assets/pbr/waterstone/roughness.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float ao : 								sample(import Texture2D("../../Assets/pbr/waterstone/ao.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).X;
			float3 TangentNormal: Vector.Normalize(	sample(import Texture2D("../../Assets/pbr/waterstone/normal.png"), TexCoord, Uno.Graphics.SamplerState.LinearWrap).XYZ * 2.0f - 1.0f);	
		}*/

	}

}