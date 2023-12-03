/**
* Name: interHerd2
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: 
*/

model interHerd4_10

/* Insert your model definition here */
global {
//	float cRange <- 100.0; // 15.0;
	float cRange <-  50.0;
	int cCull <- 16;
	int vNbContacts;
	int vNbFarmsSmallInfected <- 0;
	int vNbFarmsMediumInfected <- 0;
	int vNbFarmsLargeInfected <- 0;
	int cNbFarmsSmall <- 700;
	int cNbFarmsMedium <- 200;
	int cNbFarmsLarge <- 50;
//	int cNbFarmsSmall <- 5499;
//	int cNbFarmsMedium <- 1989;
//	int cNbFarmsLarge <- 394;
	int vSmallDirectSmall <- 0;
	int vSmallIndirectSmall <- 0;
	int vSmallIndirectMedium <- 0;
	int vMediumDirectSmall <- 0;
	int vMediumDirectMedium <- 0;
	int vMediumIndirectSmall <- 0;
	int vMediumIndirectMedium <- 0;
	int vMediumIndirectLarge <- 0;
	int vLargeDirectMedium <- 0;
	int vLargeIndirectMedium <- 0;
	int vLargeIndirectLarge <- 0;
	
	float kContact <- 1.0;
//	float kContact <- 0.75;
//	float kContact <- 0.5*0.5;
	init {
		/* Medium farms */
		create sFarm number: cNbFarmsMedium {
			aDispSize <- 6;
			location <- {rnd(2,98), rnd(2,98)};
		}
		one_of(sFarm).isInfected <- true;
		vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
		
		/* Small farms */
		create sFarm number: cNbFarmsSmall {
			aDispSize <- 3;
			location <- {rnd(2,98), rnd(2,98)};
		}
		/* Large farms */
		create sFarm number: cNbFarmsLarge {
			aDispSize <- 12;
			location <- {rnd(2,98), rnd(2,98)};
		}
	}
	reflex pause when: cycle = 52 {
		save ("Verify") to: "../includes/verify.txt" type: "text" rewrite: true;
		ask sFarm {
			save (name + " " + string(aDispSize)) to: "../includes/verify.txt" type: "text" rewrite: false;
			if (aDispSize = 3) {
//				save ("Direct Small: " + string(aTotalDirectSmall/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
//				save ("Indirect Small: " + string(aTotalIndirectSmall/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
//				save ("Indirect Medium: " + string(aTotalIndirectMedium/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
				vSmallDirectSmall <- vSmallDirectSmall + aTotalDirectSmall;
				vSmallIndirectSmall <- vSmallIndirectSmall + aTotalIndirectSmall;
				vSmallIndirectMedium <- vSmallIndirectMedium + aTotalIndirectMedium;
			} else if (aDispSize = 6) {
//				save ("Direct Small: " + string(aTotalDirectSmall/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
//				save ("Direct Medium: " + string(aTotalDirectMedium/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
//				save ("Indirect Small: " + string(aTotalIndirectSmall/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
//				save ("Indirect Medium: " + string(aTotalIndirectMedium/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
//				save ("Indirect Large: " + string(aTotalIndirectLarge/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
				vMediumDirectSmall <- vMediumDirectSmall + aTotalDirectSmall;
				vMediumDirectMedium <- vMediumDirectMedium + aTotalDirectMedium;
				vMediumIndirectSmall <- vMediumIndirectSmall + aTotalIndirectSmall;
				vMediumIndirectMedium <- vMediumIndirectMedium + aTotalIndirectMedium;
				vMediumIndirectLarge <- vMediumIndirectLarge + aTotalIndirectLarge;
			} else if (aDispSize = 12) {
//				save ("Direct Medium: " + string(aTotalDirectMedium/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
//				save ("Indirect Medium: " + string(aTotalIndirectMedium/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
//				save ("Indirect Large: " + string(aTotalIndirectLarge/52)) to: "../includes/verify.txt" type: "text" rewrite: false;
				vLargeDirectMedium <- vLargeDirectMedium + aTotalDirectMedium;
				vLargeIndirectMedium <- vLargeIndirectMedium + aTotalIndirectMedium;
				vLargeIndirectLarge <- vLargeIndirectLarge + aTotalIndirectLarge;
			} else {
				write "[Error] Invalid farm type: " + string(aDispSize);
			}
		}
		float vExpect <- 0.072;
		float vTmp <- vSmallDirectSmall/cNbFarmsSmall/52;
		write "vSmallDirectSmall:  \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		vExpect <- 0.282;
		vTmp <- vSmallIndirectSmall/cNbFarmsSmall/52;
		write "vSmallIndirectSmall:  \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		vExpect <- 0.282;
		vTmp <- vSmallIndirectMedium/cNbFarmsSmall/52;
		write "vSmallIndirectMedium:  \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		vExpect <- 0.072;
		vTmp <- vMediumDirectSmall/cNbFarmsMedium/52;
		write "vMediumDirectSmall:  \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		vExpect <- 0.073;
		vTmp <- vMediumDirectMedium/cNbFarmsMedium/52;
		write "vMediumDirectMedium:  \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		vExpect <- 0.282;
		vTmp <- vMediumIndirectSmall/cNbFarmsMedium/52;
		write "vMediumIndirectSmall:  \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		vExpect <- 0.271;
		vTmp <- vMediumIndirectMedium/cNbFarmsMedium/52;
		write "vMediumIndirectMedium: \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		vExpect <- 0.271;
		vTmp <- vMediumIndirectLarge/cNbFarmsMedium/52;
		write "vMediumIndirectLarge:  \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		vExpect <- 0.073;
		vTmp <- vLargeDirectMedium/cNbFarmsLarge/52;
		write "vLargeDirectMedium:  \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		vExpect <- 3.5;
		vTmp <- vLargeIndirectMedium/cNbFarmsLarge/52;
		write "vLargeIndirectMedium:  \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		vExpect <- 3.5;
		vTmp <- vLargeIndirectLarge/cNbFarmsLarge/52;
		write "vLargeIndirectLarge:  \tExpect: " + string(vExpect) + " \t - Actual: " + string (vTmp with_precision 3) + "\t - Error: " + string((abs(vTmp - vExpect)*100/vExpect) with_precision 2) + " %" ;
		do pause;
	}
	reflex rContacts {
		write "Week: " + string(cycle);
		/* Clear contacts and Initialize new number of contacts */
		vNbContacts <- 0;
		ask sFarm {
			aListDirectSmall <- [];
			aListDirectMedium <- [];
			aListIndirectSmall <- [];
			aListIndirectMedium <- [];
			aListIndirectLarge <- [];
			aListInfected <- [];
			aListInfect <- [];
			aDirectSmall <- 0;
			aDirectMedium <- 0;
			aIndirectSmall <- 0;
			aIndirectMedium <- 0;
			aIndirectLarge <- 0;
			if (aDispSize != 3 and aDispSize != 6 and aDispSize != 12) {
				write "[Error] Invalid farm type: " + string(aDispSize);
			}
			if (aDispSize = 3) {
				aDirectSmall <- poisson(0.072*kContact);	// Số lần 1 Small farm chuyển lợn sang các Small farms khác trong 1 tuần
				aIndirectSmall <- poisson(0.282*kContact);	// Số lần 1 Small farm nhận indirect contact từ các Small farms khác trong 1 tuần
				aIndirectMedium <- poisson(0.282*kContact);	// Số lần 1 Small farm nhận indirect contact từ các Medium farms trong 1 tuần
			} else if (aDispSize = 6) {
				aDirectSmall <- poisson(0.072*kContact); 	// Số lần 1 Medium farm chuyển lợn sang các Small farms trong 1 tuần
				aIndirectSmall <- poisson(0.282*kContact);	// Số lần 1 Medium farm nhận indirect contact từ các Small farms trong 1 tuần
				aDirectMedium <- poisson(0.073*kContact);	// Số lần 1 Medium farm chuyển lợn sang các Medium farms khác trong 1 tuần
				aIndirectMedium <- poisson(0.271*kContact);	// Số lần 1 Medium farm nhận indirect contact từ các Medium farms khác trong 1 tuần
				aIndirectLarge <- poisson(0.271*kContact);	// Số lần 1 Medium farm nhận indirect contact từ các Large farms trong 1 tuần
			} else if (aDispSize = 12) {
				aDirectMedium <- poisson(0.073*kContact);	// Số lần 1 Large farm chuyển lợn sang các Medium farm trong 1 tuần
				aIndirectMedium <- poisson(3.5*kContact);	// Số lần 1 Large farm nhận indirect contact từ các Medium farms trong 1 tuần
				aIndirectLarge <- poisson(3.5*kContact);	// Số lần 1 Large farm nhận indirect contact từ các Large farms khác trong 1 tuần
			} else
			{
//				write "[Error] Invalid farm type: " + string(aDispSize);
			}
			vNbContacts <- vNbContacts + aDirectSmall + aDirectMedium + aIndirectSmall + aIndirectMedium + aIndirectLarge;
			aTotalDirectSmall <- aTotalDirectSmall + aDirectSmall;
			aTotalDirectMedium <- aTotalDirectMedium + aDirectMedium;
			aTotalIndirectSmall <- aTotalIndirectSmall + aIndirectSmall;
			aTotalIndirectMedium <- aTotalIndirectMedium + aIndirectMedium;
			aTotalIndirectLarge <- aTotalIndirectLarge + aIndirectLarge;
		}
//		write "[Info] Number of contacts ~ " + string(vNbContacts);
//		write "[Info] Number of infected: " + string(vNbFarmsSmallInfected + vNbFarmsMediumInfected + vNbFarmsLargeInfected);
//		write "[Info] Number of Small infected: " + string(vNbFarmsSmallInfected);
//		write "[Info] Number of Medium infected: " + string(vNbFarmsMediumInfected);
//		write "[Info] Number of Large infected: " + string(vNbFarmsLargeInfected);
		
		/* Create contacts */
		ask sFarm {
			/* Direct contact to Small farm */
			loop times: aDirectSmall {	
				ask sFarm at_distance cRange {
					if (aDispSize = 3 and not(myself.aListDirectSmall contains self)) {
						add self to: myself.aListDirectSmall;
						break;
					}
				}
			}
			
			/* Direct contact to Medium farm */
			loop times: aDirectMedium {	
				ask sFarm at_distance cRange {
					if (aDispSize = 6 and not(myself.aListDirectMedium contains self)) {
						add self to: myself.aListDirectMedium;
						break;
					}
				}
			}
			
			/* Get indirect contact from Small farm */
			loop times: aIndirectSmall {
				ask sFarm at_distance cRange {
					if (aDispSize = 3 and not(myself.aListIndirectSmall contains self)) {
						add self to: myself.aListIndirectSmall;
						break;
					}
				}
			}
			
			/* Get indirect contact from Medium farm */
			loop times: aIndirectMedium {
				ask sFarm at_distance cRange {
					if (aDispSize = 6 and not(myself.aListIndirectMedium contains self)) {
						add self to: myself.aListIndirectMedium;
						break;
					}
				}
			}
			
			/* Get indirect contact from Large farm */
			loop times: aIndirectLarge {
				ask sFarm at_distance cRange {
					if (aDispSize = 12 and not(myself.aListIndirectLarge contains self)) {
						add self to: myself.aListIndirectLarge;
						break;
					}
				}
			}
		}
	
		/* Verify */
		ask sFarm {
			if ((aDirectSmall != length(aListDirectSmall)) or
				(aDirectMedium != length(aListDirectMedium)) or
				(aIndirectSmall != length(aListIndirectSmall)) or
				(aIndirectMedium != length(aListIndirectMedium)) or
				(aIndirectLarge != length(aListIndirectLarge))
			) {
				write "[Error] Missing contacts";
			}
		}
//		int i <- 0;
//		ask sFarm {
//			if aDispSize = 12 {
//				i <- i + 1;
//				write string(i) + ". " + name;
//				write string(i) + ". " + "Medium: " + string(aIndirectMedium) + " " + string(aListIndirectMedium);
//				write string(i) + ". " + "Large:" + string(aIndirectLarge) + string(aListIndirectLarge);
//			}
//		}
	}
}

species sFarm schedules: shuffle(sFarm){
	bool isInfected <- false;
	int aNbWeeks <- 0;
	int aDispSize <- 0;
	list<sFarm> aListDirectSmall <- [];
	list<sFarm> aListDirectMedium <- [];
	list<sFarm> aListIndirectSmall <- [];
	list<sFarm> aListIndirectMedium <- [];
	list<sFarm> aListIndirectLarge <- [];
	list<sFarm> aListInfected <- [];
	list<sFarm> aListInfect <- [];
	int aDirectSmall <- 0;
	int aDirectMedium <- 0;
	int aIndirectSmall <- 0;
	int aIndirectMedium <- 0;
	int aIndirectLarge <- 0;
	int aTotalDirectSmall <- 0;
	int aTotalDirectMedium <- 0;
	int aTotalIndirectSmall <- 0;
	int aTotalIndirectMedium <- 0;
	int aTotalIndirectLarge <- 0;
	aspect default {
	    draw circle(aDispSize/10) color: isInfected ? #red : #green;
//		loop vFarm over: aListInfect {
//	    	draw line([location, vFarm.location]) color: #orange end_arrow:0.6;
//	    }
//	    loop vFarm over: aListInfected {
//	    	draw line([location, vFarm.location]) color: #yellow end_arrow:0.6;
//	    }
	}
	reflex rInfected {
		if !isInfected {
			loop vFarm over: aListIndirectSmall {
				if vFarm.isInfected {
					if (aDispSize != 12) {
						if flip(0.6) {
							isInfected <- true;
							add vFarm to: aListInfected;
							if (aDispSize = 3) {
								vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
							} else {
								vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
							}
							break;
						}
					} else {
						write "[Error] Large farm does not get indirect contact from Small farm";
					}
				}
			}
		}
		if !isInfected {
			loop vFarm over: aListIndirectMedium {
				if vFarm.isInfected {
					if (aDispSize != 12) {
						if flip(0.6) {
							isInfected <- true;
							add vFarm to: aListInfected;
							if (aDispSize = 3) {
								vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
							} else {
								vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
							}
							break;
						}
					} else {
						if flip(0.006) {
//							write("Hello infected Large from Mdeium");
							isInfected <- true;
							add vFarm to: aListInfected;
							vNbFarmsLargeInfected <- vNbFarmsLargeInfected + 1;
							break;
						}
					}
				}
			}
		}
		if !isInfected {
			loop vFarm over: aListIndirectLarge {
				if vFarm.isInfected {
					if (aDispSize != 12) {
						if flip(0.6) {
							isInfected <- true;
							add vFarm to: aListInfected;
							if (aDispSize = 3) {
								vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
							} else {
								vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
							}
							break;
						}
					} else {
						if flip(0.006) {
//							write("Hello infected Large from Large");
							isInfected <- true;
							add vFarm to: aListInfected;
							vNbFarmsLargeInfected <- vNbFarmsLargeInfected + 1;
							break;
						}
					}
				}
			}
		}
	}
	
	reflex rInfect {
		if isInfected {
//			aNbWeeks <- aNbWeeks + 1;
//			if aNbWeeks >= cCull {
//				do die;
//			}
			loop vFarm over: aListDirectSmall {
				if !vFarm.isInfected {
					if (aDispSize != 12) {
						if flip(0.6) {
							vFarm.isInfected <- true;
							add vFarm to: aListInfect;
							vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
						}
					} else {
						write "[Error] Large farm does not direct contact to Small farm";
					}
				}
			}
			loop vFarm over: aListDirectMedium {
				if !vFarm.isInfected {
					if (aDispSize != 3) {
						if flip(0.6) {
							vFarm.isInfected <- true;
							add vFarm to: aListInfect;
							vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
						}
					} else {
						write "[Error] Small farm does not direct contact to Medium farm";
					}
				}
			}
		}
	}

}

experiment myExp type: gui {
	output {
		display myDisp {
			species sFarm aspect: default;
		}
		display myChart3 refresh: every(1 #cycles) {
			chart "Phần trăm trang trại bị nhiễm bệnh" type: series {
				data "Small" value: vNbFarmsSmallInfected/cNbFarmsSmall color: #red;
				data "Medium" value: vNbFarmsMediumInfected/cNbFarmsMedium color: #orange;
				data "Large" value: vNbFarmsLargeInfected/cNbFarmsLarge color: #green;
//				data "Culled" value: vNbFarmsCulled/cNbFarmsTotal color: #black;
			}
		}
	}
}