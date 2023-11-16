addpath('/home/djw216/wbic/Scripts/palm-alpha119/')

palm -i degree_npc2.csv -evperdat ucbj_npc2.csv 1 1 -d covariates_nogm_npc.csv -t design.con -evperdat gm_npc2.csv 1 2 -d covariates_gm_npc.csv -t design2.con -evperdat noddi_npc.csv 1 3 -d covariates_nogm_npc.csv -t design.con -n 10000 -o results/ -fdr -demean -npccon


