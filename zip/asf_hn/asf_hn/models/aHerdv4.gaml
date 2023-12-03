/**
* Name: aHerdv3
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: 
*/


model aHerdv3

/* Insert your model definition here */
global {
	file myRoad <- file("../includes/Thaiha_line.shp");
	file myRoomS <- file("../includes/Thaiha_S.shp");
	file myRoomPW <- file("../includes/Thaiha_PW.shp");
	file myRoomF <- file("../includes/Thaiha_F.shp");
	file myRoomPWvs <- file("../includes/Thaiha_PW_vs.shp");
	file myRoomFvs <- file("../includes/Thaiha_F_vs.shp");
	int nb_sow <- 5 update: 5;
	geometry shape <- envelope(myRoad);
	geometry building <- envelope(myRoomS);
	float step <- 1 #h;
	
	float k_S_IN <- 0.04;
	float k_IN_IP <- 0.002971766012; // week: 0.3934693403; day: 0.0689372203; hour: 0.002971766012
	float k_IP_CP <- 1 - (1 - (1 - exp(-1/lognormal_rnd(4, 1.8))))^(1/168); // week: ^1; day: ^(1/7); hour: ^(1/168) // 168 = 24 * 7
	float k_CP_IP_R <- 0.00132735371; // week: 0.2; day: 0.03137491407 ; hour: 0.00132735371
	float k_CP_IP_S <- 0.003036010683; // week: 0.4; day: 0.0703760125 ; hour: 0.003036010683 //Khi có điều kiện căng thẳng ví dụ cai sữa
	
	float k_infect <- 0.5; // Xác xuất lây nhiễm trong khu vệ sinh có vi khuẩn
	float k_infected <- 0.2; // Xác xuất làm lây nhiễm khu vệ sinh
	float k_clean <- 0.9;	// Xác xuất khi vệ sinh chuồng loại bỏ được vi khuẩn ở khu vệ sinh
	int k_clean_cycle <- 7; // Chu kỳ vệ sinh chuồng 
	
	int nb_S <- nb_sow update: pig count (each.is_S);
	int nb_IN <- 0 update: pig count (each.is_IN);
	int nb_IP <- 0 update: pig count (each.is_IP);
	int nb_CP <- 0 update: pig count (each.is_CP);
	
	int nb_S_o <- 0;
	int nb_IN_o <- 0;
	int nb_IP_o <- 0;
	int nb_CP_o <- 0;
	
	init {
		create road from: myRoad;
		create roomS from: myRoomS;
		create roomPW from: myRoomPW;
		create roomF from: myRoomF;
		create roomPWvs from: myRoomPWvs;
		create roomPWvs from: myRoomFvs;
		ask nb_sow among pig {}
		create pig number:nb_sow {
			location <- any_location_in(one_of(roomS));
			age <- 172; // 25 ngày bú sữa mẹ + 147 ngày nuôi lớn
			is_sow <- true;		
		}
		create pig number:1 {
			location <- any_location_in(one_of(roomPW));
			age <- 25; // 25 ngày bú sữa mẹ + 147 ngày nuôi lớn
			is_S <- false;
			is_IN <- true;
			room <- 1;
		}
		create pig number:nb_sow * 10 {
			location <- any_location_in(one_of(roomPW));
			age <- 25;
			is_sow <- false;
			room <- 1;
		}
		
	}
	reflex log when: mod(cycle, 24) = 0 {
		write "Day: " + int(cycle/24);
	}
	reflex add_pigs when: mod(cycle, 24) = 0 and mod(int(cycle/24) - 122, 147) = 0 { // 122 = 5 ngày lên giống + (115 + 2) ngày mang thai 
		create pig number:nb_sow * 10 {
			age <- 0;
			location <- any_location_in(one_of(roomS));	
		}	
	}
	reflex pause when: cycle = 24*122 or cycle = 24 * 147 or cycle = 24 * 154 {
		do pause;
	}
}

species road {
	aspect geom {
		draw shape color: #black;
	}
}

species roomS {
	aspect geom {
		draw shape color: #gray;
	}
}

species roomPW {
	aspect geom {
		draw shape color: #gray;
	}
}

species roomF {
	aspect geom {
		draw shape color: #gray;
	}
}
species roomPWvs {
	bool is_infected <- true;
	aspect geom {
		draw shape color: is_infected ? #red : #green;
	}
	reflex infect {
		ask pig at_distance 0 #m {
			if myself.is_infected {
				if is_S and flip(k_infect) {
					is_S <- false;
					is_IN <- true;
				}
			}
			else {
				if is_IN or is_IP {
					if flip(k_infected) {
						myself.is_infected <- true;
					}
				}
			}
		}
	}
	reflex clean when: mod(cycle, 24*k_clean_cycle) = 0 {
		if flip(k_clean) {
			is_infected <- false;
		}
	}
}

species pig skills:[moving]{		
	int age <-0;
	bool is_sow <- false;
	bool is_S <- true;
	bool is_IN <- false;
	bool is_IP <- false;
	bool is_CP <- false;
	int room <- 0;
//	float speed  <- 0.3 update: rnd(3)/10 #m/#h;
	aspect circle {
		draw circle((int(age/60)+1)/4) color: is_S ? #green : (is_IN ? #brown : (is_IP ? #red : #orange));
	}
	reflex move{
		if room = 0 {
			speed  <- rnd(3)/10/3 #m/#h;
			do wander bounds:one_of(roomS);
		}
		if room = 1 {
			speed  <- rnd(3)/10 #m/#h;
			do wander bounds:one_of(roomPW);
		}
		if room = 2 {
			speed  <- rnd(3)/10/3 #m/#h;
			do wander bounds:one_of(roomF);
		}
	}
	reflex growth {
		if mod(cycle, 24) = 0 {
			age <- age + 1;
		}	
	}
	reflex relocate {
		if is_sow = false and age = 25 {
			room <- 1;
			location <- any_location_in(one_of(roomPW));
		}
		if is_sow = false and age = 172 {
			room <- 2;
			location <- any_location_in(one_of(roomF));
		}
		if is_sow = true and age = 319 {
			room <- 2;
			location <- any_location_in(one_of(roomF));
		}
	}
	reflex finish when: (is_sow and age = 327) or (is_sow = false and age = 180){
		if is_S {
			nb_S_o <- nb_S_o + 1;
		}
		if is_IN {
			nb_IN_o <- nb_IN_o + 1;
		}
		if is_IP {
			nb_IP_o <- nb_IP_o + 1;
		}
		if is_CP {
			nb_CP_o <- nb_CP_o + 1;
		}
		do die;
	}
	reflex prepare when: mod(cycle, 24) = 0 and nb_sow > 0 and is_sow = false and age = 172 {
		is_sow <- true;
		nb_sow <- nb_sow - 1;
		room <- 0;
		location <- any_location_in(one_of(roomS));
		write "Hello " + nb_sow;
	}
	reflex infect when: is_S = false{
		ask pig at_distance 1 #m {
			if is_S {
				if flip(k_S_IN) {
					is_S <- false;
					is_IN <- true;
				}
			}
		}
	}
	reflex transf_IN_IP when: is_IN {
		if flip(k_IN_IP) {
			is_IN <- false;
			is_IP <- true;
		}
	}
	reflex transf_IP_CP when: is_IP {
		if flip(k_IP_CP) {
			is_IP <- false;
			is_CP <- true;
		}
	}
	reflex transf_CP_IP when: is_CP {
		if (age > 25 and age <= 30) {
			if flip(k_CP_IP_S) {
				is_CP <- false;
				is_IP <- true;
			}
		}
		else {
			if flip(k_CP_IP_R) {
				is_CP <- false;
				is_IP <- true;
			}
		}
	}
}
experiment Exp type: gui {
	parameter "Number of sows at init" var: nb_sow min: 1 max: 300;
	output {
		display map {
//			image "../includes/Thaiha_background.png" refresh: false; 
			species road aspect:geom refresh: false;
			species pig aspect:circle;
			species roomS aspect:geom refresh: false transparency: 0.75;
			species roomPW aspect:geom refresh: false transparency: 0.75;
			species roomF aspect:geom refresh: false transparency: 0.75;
			species roomPWvs aspect:geom refresh: false transparency: 0.75;
		}
		display chart_display refresh: every(1 #cycles) {
			chart "Trong trại" type: series {
				data "nb_S" value: nb_S color: #green;
				data "nb_IN" value: nb_IN color: #brown;
				data "nb_IP" value: nb_IP color: #red;
				data "nb_CP" value: nb_CP color: #orange;
			}
		}
		display Test refresh: every(1 #cycles) {
			chart "Xuất chuồng" type: series {
				data "nb_S" value: nb_S_o color: #green;
				data "nb_IN" value: nb_IN_o color: #brown;
				data "nb_IP" value: nb_IP_o color: #red;
				data "nb_CP" value: nb_CP_o color: #orange;
			}
		}
	}
}
