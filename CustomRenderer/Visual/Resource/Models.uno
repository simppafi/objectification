using Uno;
using Uno.Collections;
using Fuse;
using Uno.Content.Models;

namespace simppafi
{
	public static class Models
	{
		/*
		public static Model		lett_a = import Model("../../Assets/letters/char_A.FBX");
		public static Model		lett_b = import Model("../../Assets/letters/char_B.FBX");
		public static Model		lett_c = import Model("../../Assets/letters/char_C.FBX");
		public static Model		lett_d = import Model("../../Assets/letters/char_D.FBX");
		public static Model		lett_e = import Model("../../Assets/letters/char_E.FBX");
		public static Model		lett_f = import Model("../../Assets/letters/char_F.FBX");
		public static Model		lett_g = import Model("../../Assets/letters/char_G.FBX");
		public static Model		lett_h = import Model("../../Assets/letters/char_H.FBX");
		public static Model		lett_i = import Model("../../Assets/letters/char_I.FBX");
		public static Model		lett_j = import Model("../../Assets/letters/char_J.FBX");
		public static Model		lett_k = import Model("../../Assets/letters/char_K.FBX");
		public static Model		lett_l = import Model("../../Assets/letters/char_L.FBX");
		public static Model		lett_m = import Model("../../Assets/letters/char_M.FBX");
		public static Model		lett_n = import Model("../../Assets/letters/char_N.FBX");
		public static Model		lett_o = import Model("../../Assets/letters/char_O.FBX");
		public static Model		lett_p = import Model("../../Assets/letters/char_P.FBX");
		public static Model		lett_q = import Model("../../Assets/letters/char_Q.FBX");
		public static Model		lett_r = import Model("../../Assets/letters/char_R.FBX");
		public static Model		lett_s = import Model("../../Assets/letters/char_S.FBX");
		public static Model		lett_t = import Model("../../Assets/letters/char_T.FBX");
		public static Model		lett_u = import Model("../../Assets/letters/char_U.FBX");
		public static Model		lett_v = import Model("../../Assets/letters/char_V.FBX");
		public static Model		lett_w = import Model("../../Assets/letters/char_W.FBX");
		public static Model		lett_x = import Model("../../Assets/letters/char_X.FBX");
		public static Model		lett_y = import Model("../../Assets/letters/char_Y.FBX");
		public static Model		lett_z = import Model("../../Assets/letters/char_Z.FBX");
		public static Model		lett_hash = import Model("../../Assets/letters/char_HASH.FBX");
		public static Model		lett_at = import Model("../../Assets/letters/char_AT.FBX");
		public static Model		lett_0 = import Model("../../Assets/letters/char_0.FBX");
		public static Model		lett_1 = import Model("../../Assets/letters/char_1.FBX");
		public static Model		lett_2 = import Model("../../Assets/letters/char_2.FBX");
		public static Model		lett_3 = import Model("../../Assets/letters/char_3.FBX");
		public static Model		lett_4 = import Model("../../Assets/letters/char_4.FBX");
		//public static Model		lett_5 = import Model("../../Assets/letters/char_5.FBX"); // this is broken, so no 5. :( 0 fucks given though
		public static Model		lett_6 = import Model("../../Assets/letters/char_6.FBX");
		public static Model		lett_7 = import Model("../../Assets/letters/char_7.FBX");
		public static Model		lett_8 = import Model("../../Assets/letters/char_8.FBX");
		public static Model		lett_9 = import Model("../../Assets/letters/char_9.FBX");

		public static Model[] 	letters = new [] {	lett_0,lett_1,lett_2,lett_3,lett_4,lett_6,lett_7,lett_8,lett_9,
													lett_a,lett_b,lett_c,lett_d,lett_e,lett_f,lett_g,lett_h,lett_i,lett_j,lett_k,
													lett_l,lett_m,lett_n,lett_o,lett_p,lett_q,lett_r,lett_s,lett_t,lett_u,lett_v,lett_w,lett_x,
													lett_y,lett_z,lett_at,lett_hash};
													*/
		

		//public static Model		cobra = import Model("../../Assets/models/cobra.fbx");

		//public static Model		lambo = import Model("../../Assets/models/lambor.fbx");

		//public static Model		sphere = import Model("../../Assets/models/sphere.fbx");
/*
		public static Model		voronoitetrahedron = import Model("../../Assets/models/uv_mapped_tetrahedron_voronoi.fbx");

		public static Model		voronoisphere = import Model("../../Assets/models/voronoi_sphere_less2.fbx");

		public static Model		voronoihexacon = import Model("../../Assets/models/voronoi_hexacon.fbx");

		public static Model		voronoidodecahedron = import Model("../../Assets/models/uv_mapped_dodecahedron_voronoi3.fbx");

		public static Model		voronoicube = import Model("../../Assets/models/uv_mapped_cube_voronoi.fbx");

		public static Model		voronoiicosahedron = import Model("../../Assets/models/uv_mapped_icosahedron_voronoi.fbx");

		public static Model		voronoioctahedron = import Model("../../Assets/models/uv_mapped_octahedron_voronoi.fbx");
*/

		//public static Model		rockArm = import Model("../../Assets/models/rockarm/rockArm.DAE");

		//public static Model 	skull = import Model("../../Assets/models/new/skull2.fbx");

		//public static Model 	lada = import Model("../../Assets/models/lada.fbx");

		//public static Model 	head = import Model("../../Assets/models/bolvanka/bolvanka.fbx");
		//public static Model 	headMale = import Model("../../Assets/models/head/random head-FBX/random head.FBX");

		//public static Model		head1 = import Model("../../Assets/models/heads/head3.fbx");

		//public static Model 	skull = import Model("../../Assets/models/new/skull2.fbx");

		//public static Model		debris1 = import Model("../../Assets/models/z_debris_big_01.FBX");

		//public static Model 	fighterInParts = import Model("../../Assets/models/space2/geoFighter_pieces.FBX");

		//public static Model		rock1 = import Model("../../Assets/models/rockjonny/rock.DAE");
		//public static Model		rock2 = import Model("../../Assets/models/rockjonny/rock2.DAE");
		//public static Model		rock3 = import Model("../../Assets/models/rockjonny/rock3.DAE");
		//public static Model		rock4 = import Model("../../Assets/models/rocktyro/Rock1.dae");


		//public static Model		planehole1 = import Model("../../Assets/models/plane_hole1.fbx");


		//public static Model		stairs1 = import Model("../../Assets/models/stairs/stairs1.fbx");

		//public static Model		cube_rounded = import Model("../../Assets/models/cube_rounded2.fbx");

		//public static Model		robo1 = import Model("../../Assets/models/bots/bot1.fbx");


		//public static Model		robo1_part2 = import Model("../../Assets/models/bots/bot1_part2.fbx");

		//public static Model		hand = import Model("../../Assets/models/hand_round.fbx");

		public static Model		female = import Model("../../Assets/models/female4.fbx");
		public static Model		female_head = import Model("../../Assets/models/female_head_broken.fbx");
		

		public static Model		people1 = import Model("../../Assets/models/people/people1.fbx"); //2x
		public static Model		people2 = import Model("../../Assets/models/people/people2.fbx"); //2x
		public static Model		people3 = import Model("../../Assets/models/people/people3.fbx"); //2x
		public static Model		people4 = import Model("../../Assets/models/people/people4.fbx"); //2x
		public static Model		people5 = import Model("../../Assets/models/people/people5.fbx"); //2x
		public static Model		people6 = import Model("../../Assets/models/people/people6.fbx"); //1x
		public static Model		people7 = import Model("../../Assets/models/people/people7.fbx"); //2x
		public static Model		people8 = import Model("../../Assets/models/people/people8.fbx"); //1x
		public static Model		people9 = import Model("../../Assets/models/people/people9.fbx"); //1x
		public static Model		people10 = import Model("../../Assets/models/people/people10.fbx");  //1x
		public static Model		people11 = import Model("../../Assets/models/people/people11.fbx");  //1x
		public static Model		people12 = import Model("../../Assets/models/people/people12.fbx"); //2x
		public static Model		people13 = import Model("../../Assets/models/people/people13.fbx"); //2x
		public static Model		people14 = import Model("../../Assets/models/people/people14.fbx"); //2x
		public static Model		people15 = import Model("../../Assets/models/people/people15.fbx"); //1x
		public static Model		people16 = import Model("../../Assets/models/people/people16.fbx"); //1x
		public static Model		people17 = import Model("../../Assets/models/people/people17.fbx"); //1x
		public static Model		people18 = import Model("../../Assets/models/people/people18.fbx"); //1x
		public static Model		people19 = import Model("../../Assets/models/people/people19.fbx"); //1x
		public static Model		people20 = import Model("../../Assets/models/people/people20.fbx"); //0x
		public static Model		people21 = import Model("../../Assets/models/people/people21.fbx"); //0x
		
		//public static Model[] 	rocks = new [] {	rock3,rock4}; //rock2 //rock1


		//public static Model		lion = import Model("../../Assets/models/lion/lion.fbx");



		//public static Model		car = import Model("../../Assets/models/car.fbx");
		

	}
}
