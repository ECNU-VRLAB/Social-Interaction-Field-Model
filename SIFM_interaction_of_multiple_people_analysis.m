clear all;clc;warning('off');
load('data.mat');

for iScene = 1:size(position,1)
    group_interaction = struct();
    for iGroupsize = 2:position.PeopleNo(iScene)
        all_possible_combinations = combntns(1:position.PeopleNo(iScene),iGroupsize);
        interaction_martix = eye(iGroupsize);
        for iDydic = 1:size(all_possible_combinations,1)
                    Dydic_intensity = [];
            current_dydic_group = combntns(all_possible_combinations(iDydic,:),2);
            for iCurrentDydic = 1:size(current_dydic_group,1)
                A_x = eval(sprintf('position.P%dx(iScene)',current_dydic_group( iCurrentDydic,1)));
                A_y = eval(sprintf('position.P%dy(iScene)',current_dydic_group( iCurrentDydic,1)));
                B_x = eval(sprintf('position.P%dx(iScene)',current_dydic_group( iCurrentDydic,2)));
                B_y = eval(sprintf('position.P%dy(iScene)',current_dydic_group( iCurrentDydic,2)));
                A_orientation = eval(sprintf('orientation.P%d(iScene)',current_dydic_group( iCurrentDydic,1)));
                B_orientation = eval(sprintf('orientation.P%d(iScene)',current_dydic_group( iCurrentDydic,2)));
                vectorAB = [B_x-A_x;B_y-A_y];
                DriectionAB = [cosd(A_orientation);sind(A_orientation)];
                relativeorientation_A =360 - mod((atan2d([DriectionAB(2) -DriectionAB(1)]*vectorAB,sum(DriectionAB.*vectorAB))),360);
                vectorBA = [A_x-B_x;A_y-B_y];
                DriectionBA =  [cosd(B_orientation);sind(B_orientation)];
                relativeorientation_B=360 - mod((atan2d([DriectionBA(2) -DriectionBA(1)]*vectorBA,sum(DriectionBA.*vectorBA))),360);
                Distance = sqrt((A_x - B_x)^2 + (A_y - B_y)^2 );
                
                if relativeorientation_A >= 90 && relativeorientation_A <= 270
                    CosValueA = 0;
                else
                    CosValueA = cos((relativeorientation_A/180*pi));
                end
                if relativeorientation_B >= 90 && relativeorientation_B <= 270
                    CosValueB = 0;
                else
                    CosValueB = cos((relativeorientation_B/180*pi));
                end
                
                eval(sprintf('A_Openness = openness.P%d(iScene);',current_dydic_group( iCurrentDydic,1)));
                eval(sprintf('B_Openness = openness.P%d(iScene);',current_dydic_group( iCurrentDydic,2)));
                I_a = 0.136*A_Openness+1;
                I_b = 0.136*B_Openness+1;
                lambda = 0.172;
                a = (I_a*I_b) / lambda;
                
                b = 0.748;
                c = 0.087;
                Strength =  (CosValueA+c)*(CosValueB+c)/(Distance^2);
                Interaction_probability = 1-exp(-(Strength*a)^b);
                Dydic_intensity = [Dydic_intensity,Interaction_probability];
            end
            
            group_probability =  prod(Dydic_intensity).^(1/size(Dydic_intensity,2));
            
            group_name =  char(all_possible_combinations(iDydic,:)+64);
            eval(sprintf('group_interaction.%s = group_probability;',group_name));
            
            fprintf(fid,'%d\t',iScene);fprintf(fid,'%d\t',position.PeopleNo(iScene));fprintf(fid,'%s\t',group_name);fprintf(fid,'%8.4f\t',group_probability); fprintf(fid,'\n');
        end
    end
    scene{iScene} = group_interaction;
    clc;disp(['processing...' num2str(round(iScene/size(position,1),2)*100) '%']);
end