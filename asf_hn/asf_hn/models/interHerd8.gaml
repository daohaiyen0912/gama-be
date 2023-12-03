/**
* Name: interHerd2
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: 
*/

model interHerd7

/* Insert your model definition here */
global {
	/* Map files */
	file vMapFile <- file("../includes/QuanHuyen.shp");
	file vMapFileCenter <- file("../includes/TTQuanHuyen.shp");
	geometry shape <- envelope(vMapFile);
	bool vEnable <- true;

	/* Data files */
	file vSFile <- csv_file("../includes/Tmp10TrongDan.csv");
	file vLFile <- csv_file("../includes/CongTy.csv");
	map<string, int> vSNbFarms;
	map<string, int> vSNbTotalPigs;
	map<string, float> vSAvgPigs;
	map<string, int> vLNbFarms;
	map<string, int> vLNbTotalPigs;
	map<string, float> vLAvgPigs;
	
	int vNbPigsTotal <- 0;
	int vNbFarmsTotal <- 0;
	
	int vNbFarmsInfected <- 0;
	int vNbPigsInfected <- 0;
	int vNbFarmsSmall <- 0;
	int vNbFarmsMedium <- 0;
	int vNbFarmsLarge <- 0;
	int vNbFarmsSmallInfected <- 0;
	int vNbFarmsMediumInfected <- 0;
	int vNbFarmsLargeInfected <- 0;
	int vNbFarmsCulled <- 0;
	int vNbPigsCulled <- 0;
	
	int vTmpInt <- 0;
	int vNbContacts <- 0;
	list<list<sFarm>> vList <- [];
	
	int vCull <- 8; // weeks
	float vKContacts <- 10.0;
	
	init {
		/* Initialize maps */
		create sDistrict from: vMapFile with: [aNameEN::string(read("ADM2_EN"))];
		create sDistrictCenter from: vMapFileCenter with: [aNameVN::string(read("ADM2_VI"))];
		
		/* Parse data */
		int i <- 0;
		string vKey;

		loop it over: vSFile {	// Note: Auto ignore first line
			if (mod(i, 4) = 0) {
				vKey <- it;	
			} 
			else if (mod(i, 4) = 1) {
				add int(it) at: vKey to: vSNbFarms;
			}
			else if (mod(i, 4) = 2) {
				add int(it) at: vKey to: vSNbTotalPigs;
			}
			else {
				add int(it) at: vKey to: vSAvgPigs;
			}
			write string(i) + ". " + vKey;
			i <- i + 1;
		}
		
		i <- 0;
		loop it over: vLFile { // Note: Auto ignore first line
			if (mod(i, 4) = 0) {
				vKey <- it;	
			} 
			else if (mod(i, 4) = 1) {
				add int(it) at: vKey to: vLNbFarms;
			}
			else if (mod(i, 4) = 2) {
				add int(it) at: vKey to: vLNbTotalPigs;
			}
			else {
				add int(it) at: vKey to: vLAvgPigs;
			}
			i <- i + 1;
		}
	
		/* Initilize farms */
		sDistrict vDistrict;
		i <- 0;
		write "Initialize farms...";
		loop vDistrict over: sDistrict {
			/* Chăn nuôi trong dân */
			i <- i + 1;
			write string(i) + "/30 " + vDistrict.aNameEN;
			vDistrict.aNbFarms <- (vSNbFarms.pairs first_with (each.key = vDistrict.aNameEN)).value;
			vNbFarmsSmall <- vNbFarmsSmall + vDistrict.aNbFarms;
			loop times: vDistrict.aNbFarms {
				create sFarm number: 1 {
					location <- any_location_in(vDistrict);
					aNbPigs <- poisson((vSAvgPigs.pairs first_with (each.key = vDistrict.aNameEN)).value);
			      	vNbPigsTotal <- vNbPigsTotal + aNbPigs;
			      	vDistrict.aNbPigs <- vDistrict.aNbPigs + aNbPigs;
				}
			}
			
			/* Chăn nuôi trong cơ sở chăn nuôi */
			vTmpInt <- (vLNbFarms.pairs first_with (each.key = vDistrict.aNameEN)).value;
			vDistrict.aNbFarms <- vDistrict.aNbFarms + vTmpInt;
			loop times: vTmpInt {
				create sFarm number: 1 {
					location <- any_location_in(vDistrict);
					aNbPigs <- round((vLAvgPigs.pairs first_with (each.key = vDistrict.aNameEN)).value);
					if (aNbPigs < 100) {
						vNbFarmsSmall <- vNbFarmsSmall + 1;
					} else if (aNbPigs < 1000) {
						vNbFarmsMedium <- vNbFarmsMedium + 1;
					} else {
						vNbFarmsLarge <- vNbFarmsLarge + 1;
					}
			      	vNbPigsTotal <- vNbPigsTotal + aNbPigs;
			      	vDistrict.aNbPigs <- vDistrict.aNbPigs + aNbPigs;
				}
			}
			vNbFarmsTotal <- vNbFarmsTotal + vDistrict.aNbFarms;
		}
		write "Total pigs: " + string(vNbPigsTotal);
		write "Total Farms: " + string(vNbFarmsTotal);
		write "Total Small Farms: " + string(vNbFarmsSmall);
		write "Total Medium Farms: " + string(vNbFarmsMedium);
		write "Total Large Farms: " + string(vNbFarmsLarge);
		
		/* Initialize contacts */
		vNbContacts <- int(vNbFarmsTotal * vKContacts);
		vTmpInt <- vNbContacts;
		int vTmp <- round(vNbContacts/10);
		list<sFarm> vPair;
		loop while: (vTmpInt > 0) {
			bool vCheck <- true;
			loop while: vCheck {
				vPair <- (2 among sFarm.population);
				if ((vList contains vPair) or 
					(vList contains [vPair at 1, vPair at 0]) or
					((vPair at 0).aNbPigs < 100 and (vPair at 1).aNbPigs > 1000) or 
					((vPair at 0).aNbPigs > 1000 and (vPair at 1).aNbPigs < 100)) 
				{
					vCheck <- true;
				} else {
					vCheck <- false;
				}
			}
			add vPair to: vList;
			
			if ((vPair at 0).aNbPigs < 100) {
				add (vPair at 0) to: (vPair at 1).aListSmall;
			} else if ((vPair at 0).aNbPigs < 1000) {
				add (vPair at 0) to: (vPair at 1).aListMedium;
			} else {
				add (vPair at 0) to: (vPair at 1).aListLarge;
			}
			
			if ((vPair at 1).aNbPigs < 100) {
				add (vPair at 1) to: (vPair at 0).aListSmall;
			} else if ((vPair at 1).aNbPigs < 1000) {
				add (vPair at 1) to: (vPair at 0).aListMedium;
			} else {
				add (vPair at 1) to: (vPair at 0).aListLarge;
			}
			vTmpInt <- vTmpInt - 1;
			if mod(vNbContacts - vTmpInt, vTmp) = 0 {
				write "Initialize contacts " + string(round((vNbContacts - vTmpInt)/vTmp)) + "0% (" + string(vNbContacts - vTmpInt) + "/" + string(vNbContacts) + ")";
			}
		}
		write "Total contacts: " + string(vNbContacts);
		
		/* Initialize an infected farm */
		vTmpInt <- rnd(0, vNbContacts - 1);
		if flip(0.5) {
			((vList at vTmpInt) at 0).isInfected <- true;
			vNbPigsInfected <- vNbPigsInfected + ((vList at vTmpInt) at 0).aNbPigs;
			write "The first infected farm: " + ((vList at vTmpInt) at 0).name;
		} else {
			((vList at vTmpInt) at 1).isInfected <- true;
			vNbPigsInfected <- vNbPigsInfected + ((vList at vTmpInt) at 1).aNbPigs;
			write "The first infected farm: " + ((vList at vTmpInt) at 1).name;
		}
		vNbFarmsInfected <- vNbFarmsInfected + 1;
	}

	reflex update {
		write "Day: " + cycle + " Week: " + int(cycle/7);
		ask sFarm {
			isChange <- false;
			if aInfectedTime = vCull * 7 {
				vNbFarmsCulled <- vNbFarmsCulled + 1;
				vNbPigsCulled <- vNbPigsCulled + aNbPigs;
			}
		}
	}
	reflex pause when: cycle = 7 or cycle = 7 * 13 or cycle = 7 * 26 or cycle = 7*52 {
		write "vNbFarmsInfected = " + string(vNbFarmsInfected);
		write "vNbPigsInfected = " + string(vNbPigsInfected);
		write "vNbFarmsSmall = " + string(vNbFarmsSmall);
		write "vNbFarmsMedium = " + string(vNbFarmsMedium);
		write "vNbFarmsLarge = " + string(vNbFarmsLarge);
		write "vNbFarmsSmallInfected = " + string(vNbFarmsSmallInfected);
		write "vNbFarmsMediumInfected = " + string(vNbFarmsMediumInfected);
		write "vNbFarmsLargeInfected = " + string(vNbFarmsLargeInfected);
		write "vNbFarmsCulled = " + string(vNbFarmsCulled);
		write "vNbPigsCulled = " + string(vNbPigsCulled);
		do pause;
	}
}

species sDistrictCenter {
	string aNameVN <- nil;
	aspect default {
		if vEnable {
			draw circle(100) color: #yellow;
			draw aNameVN color: #black font: font('Default', 15, #bold) at: {location.x, location.y};
		}
	}
}

species sFarm {
	int aNbPigs <- 0;
	bool isInfected <- false;
	int aInfectedTime <- 0;	// days
	bool isChange <- false;
	list<sFarm> aListSmall <- [];
	list<sFarm> aListMedium <- [];
	list<sFarm> aListLarge <- [];
	aspect default {
		int tmp <-  aNbPigs < 100 ? 200 : (aNbPigs < 1000 ? 300 : 500);
	    draw circle(tmp) color: isInfected ? #red : #green; 
	}
	
	reflex update when: isInfected {
		aInfectedTime <- aInfectedTime + 1;
	}
	
//	/* FarmA delete contact with FarmB */
//	action fContactDel(sFarm aFarmA, sFarm aFarmB) { 
//		if aFarmA.aListSmall contains aFarmB {
//			write aFarmA.name + " " + aFarmB.name;
//			write aFarmA.aListSmall;
//			int vTmp <- aFarmA.aListSmall index_of aFarmB;
//			write vTmp;
//			remove from: aFarmA.aListSmall index: vTmp;
//		} else if aFarmA.aListMedium contains aFarmB {
//			remove from: aFarmA.aListMedium index: aFarmA.aListMedium index_of aFarmB;
//		} else if aFarmA.aListLarge contains aFarmB {
//			remove from: aFarmA.aListLarge index: aFarmA.aListLarge index_of aFarmB;
//		}
//	}
	
	reflex infect when: isInfected = true{
		float vDirect;
		float vIndirect;
		float vKDirect <- (aInfectedTime >= vCull * 7) ? 0 : 0.6;
		if isChange = false{
			ask target: aListSmall {
//				if isChange = false and isInfected = false {
				if isInfected = false {
					if (myself.aNbPigs < 100) {
						vDirect <- vKDirect * poisson(0.072) / length(myself.aListSmall) / 7;
						vIndirect <- 0.6 * poisson(0.282) / length(myself.aListSmall) / 7;
					} else if (myself.aNbPigs < 1000) {
						vDirect <- vKDirect * poisson(0.072) / length(myself.aListSmall) / 7;
						vIndirect <- 0.6 * poisson(0.282) / length(myself.aListSmall) / 7;
					} else {
						vDirect <- 0.0;
						vDirect <- 0.0;
					}
					
					if flip(vDirect + vIndirect) {
						isInfected <- true;
//						isChange <- true;
						vNbFarmsInfected <- vNbFarmsInfected + 1;
						vNbPigsInfected <- vNbPigsInfected + aNbPigs;
						vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
						
					}
				}
			}
			
			ask target: aListMedium {
//				if isChange = false and isInfected = false {
				if isInfected = false {
					if (myself.aNbPigs < 100) {
						vDirect <- 0.0;
						vIndirect <- 0.6 * poisson(0.282) / length(myself.aListMedium) / 7;
					} else if (myself.aNbPigs < 1000) {
						vDirect <- vKDirect * poisson(0.073) / length(myself.aListMedium) / 7;
						vIndirect <- 0.6 * poisson(0.271) / length(myself.aListMedium) / 7;
					} else {
						vDirect <- vKDirect * poisson(0.073) / length(myself.aListMedium) / 7;
						vIndirect <- 0.006 * poisson(0.271) / length(myself.aListMedium) / 7;
					}
					
					if flip(vDirect + vIndirect) {
						isInfected <- true;
//						isChange <- true;
						vNbFarmsInfected <- vNbFarmsInfected + 1;
						vNbPigsInfected <- vNbPigsInfected + aNbPigs;
						vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
					}
				}
			}
			
			ask target: aListLarge {
//				if isChange = false and isInfected = false {
				if isInfected = false {
					if (myself.aNbPigs < 100) {
						vDirect <- 0.0;
						vIndirect <- 0.0;
					} else if (myself.aNbPigs < 1000) {
						vDirect <- 0.0;
						vIndirect <- 0.006 * poisson(3.5) / length(myself.aListLarge) / 7;
					} else {
						vDirect <- 0.0;
						vIndirect <- 0.006 * poisson(3.5) / length(myself.aListLarge) / 7;
					}
					
					if flip(vDirect + vIndirect) {
						isInfected <- true;
//						isChange <- true;
						vNbFarmsInfected <- vNbFarmsInfected + 1;
						vNbPigsInfected <- vNbPigsInfected + aNbPigs;
						vNbFarmsLargeInfected <- vNbFarmsLargeInfected + 1;
					}
				}
			}
		}
	}
}

species sDistrict {
	string aNameEN <- nil;
	bool isInfected <- false;
	int aNbFarms <- 0;
	int aNbFarmsInfected <- 0;
	int aNbPigs <- 0;
	aspect default {
		if (aNbFarms = 0) {
			draw shape color: #gray border: #black;
		} else {
			aNbFarmsInfected <- 0;
			ask sFarm at_distance 0 {
				if (isInfected) {
					myself.isInfected <- true;
					myself.aNbFarmsInfected <- myself.aNbFarmsInfected + 1;
				}
			}
			
			draw shape color: isInfected ? hsb(aNbFarmsInfected/aNbFarms*(0.71-0.47)+0.47, 1, 1) : #gray border: #black;
		}	
	}
}

experiment myExperiment type: gui {
	parameter "Show District Name" category: "Display" var: vEnable <- true; 
	parameter "Timing of culling" category: "Parameters" var: vCull <- 8; 
	output {
		display myDisplay {
			species sDistrict aspect: default;
			species sFarm aspect: default;
			species sDistrictCenter aspect: default;
		}
		display myChart1 refresh: every(1 #cycles) {
			chart "Trang trại" type: series {
				data "Bị bệnh" value: vNbFarmsInfected color: #red;
				data "Không bệnh" value: vNbFarmsTotal - vNbFarmsInfected color: # green;
			}
		}
		display myChart2 refresh: every(1 #cycles) {
			chart "Số lợn" type: series {
				data "Bị bệnh" value: vNbPigsInfected color: #red;
				data "Không bệnh" value: vNbPigsTotal - vNbPigsInfected color: # green;
			}
		}
		display myChart3 refresh: every(1 #cycles) {
			chart "Phần trăm trang trại bị nhiễm bệnh" type: series {
				data "Small" value: vNbFarmsSmallInfected/vNbFarmsSmall color: #red;
				data "Medium" value: vNbFarmsMediumInfected/vNbFarmsMedium color: #orange;
				data "Large" value: vNbFarmsLargeInfected/vNbFarmsLarge color: #green;
				data "Culled" value: vNbFarmsCulled/vNbFarmsTotal color: #black;
			}
		}
		display myChart4 refresh: every(1 #cycles) {
			chart "Số trang trại bị nhiễm bệnh" type: series {
				data "Small" value: vNbFarmsSmallInfected color: #red;
				data "Medium" value: vNbFarmsMediumInfected color: #orange;
				data "Large" value: vNbFarmsLargeInfected color: #green;
				data "Culled" value: vNbFarmsCulled color: #black;
			}
		}
	}
}