clear all; warning off;
Experiment = 'ExpXX';
disp(['Now processing ' Experiment '...']);
disp(' ');
t_select = 10;

for iframe = 1:length(features)
    allG{iframe} = {};
    igroup = {};
    f = features{iframe};
    num = length(f(:,1));
    for inum = 2:num
        allgroups = [];
        subgroups = nchoosek(1:num,inum);
        [igroupnum,~] = size(subgroups);
        for ig = 1:igroupnum
            allgroups{ig} = num2str(subgroups(ig,:));
        end
        igroup{inum} = allgroups';
    end
    allG{iframe} = igroup;
end
clear iframe allgroups f num ig inum subgroups igroupnum igroup

for iframe = 1:length(features)
    currgroup = {};
    igroup = GT{iframe};
    for ig = 1:length(igroup)
        currgroup{ig} = num2str(sort(unique(igroup{ig})));
    end
    subgroup{iframe} = currgroup';
end
clear currgroup iframe GT igroup ig

l = 65;
    pregroup = com;
    for iframe = 1:length(features)
        currgroup = {};
        igroup = pregroup{iframe};
        for ig = 1:length(igroup)
            currgroup{ig} = num2str(sort(unique(igroup{ig})));
        end
        pregroup{iframe} = currgroup';
    end
    clear currgroup iframe GT igroup ig
    
    bugtrial = [];
    for iframe = 1:length(features)
        allGs = allG{iframe};
        subG = subgroup{iframe};
        preG = pregroup{iframe};
        selG = union(subG,preG);
        selidx = [];
        for i = 1:length(selG)
            for j = 1:length(selG)
                if ~isequal(selG{i},selG{j})
                    if all(ismember(str2num(selG{i}),str2num(selG{j})))
                        selG{i} = '';
                        selidx = [selidx,i];
                    elseif all(ismember(str2num(selG{j}),str2num(selG{i})))
                        selG{j} = '';
                        selidx = [selidx,j];
                    end
                end
            end
        end
        selG(selidx) = [];
        clear selidx i j
        
        TP = 0; TN = 0; FP = 0; FN = 0;
        allGnum = 0;
        for i = 2:length(allGs)
            allGnum = allGnum + length(allGs{i});
        end
        restGnum = allGnum;
        clear i
        
        for ig = 1:length(selG)
            igroup = selG{ig};
            isel = str2num(igroup);
            allselnum = 0;
            allselgroups = {};
            for iselnum = 2:length(isel)
                allgroups = {};
                subgroups = nchoosek(isel,iselnum);
                [igroupnum,~] = size(subgroups);
                allselnum = allselnum + igroupnum;
                for ignum = 1:igroupnum
                    allgroups{ignum} = num2str(subgroups(ignum,:));
                end
                allselgroups{iselnum} = allgroups';
            end
            restGnum = restGnum - allselnum;
            if restGnum < 0
                bugtrial = [bugtrial;iframe];
            end
            clear iselnum isel allgroups subgroups igroupnum ignum
            
            if ismember(igroup,subG) && ismember(igroup,preG)
                TP = TP + allselnum;
            elseif ismember(igroup,subG)
                idx = [];
                for i = 1:length(preG)
                    if all(ismember(str2num(preG{i}),str2num(igroup)))
                        idx = [idx;i];
                    end
                end
                if isempty(idx)
                    FN = FN + allselnum;
                else
                    presubG = preG(idx);
                    allpreG = {};
                    irow = 0;
                    for ii = 1:length(presubG)
                        presubgroup = presubG{ii};
                        for j = 2:length(str2num(presubgroup))
                            subgroups = nchoosek(str2num(presubgroup),j);
                            [igroupnum,~] = size(subgroups);
                            for jj = 1:igroupnum
                                irow = irow + 1;
                                allpreG{irow} = num2str(subgroups(jj,:));
                            end
                        end
                    end
                    allpreG = allpreG';
                    clear irow ii j jj presubG presubgroup subgroups igroupnum
                    
                    alligroup = {};
                    for ii = 2:length(allselgroups)
                        alligroup = [alligroup;allselgroups{ii}];
                    end
                    clear ii
                    
                    TP = TP + length(intersect(alligroup,allpreG));
                    FN = FN + length(setdiff(alligroup,allpreG));
                    clear alligroup allpreG allselgroups
                end
            elseif ismember(igroup,preG)
                idx = [];
                for i = 1:length(subG)
                    if all(ismember(str2num(subG{i}),str2num(igroup)))
                        idx = [idx;i];
                    end
                end
                if isempty(idx)
                    FP = FP + allselnum;
                else
                    subsubG = subG(idx);
                    allsubG = {};
                    irow = 0;
                    for ii = 1:length(subsubG)
                        subsubgroup = subsubG{ii};
                        for j = 2:length(str2num(subsubgroup))
                            subgroups = nchoosek(str2num(subsubgroup),j);
                            [igroupnum,~] = size(subgroups);
                            for jj = 1:igroupnum
                                irow = irow + 1;
                                allsubG{irow} = num2str(subgroups(jj,:));
                            end
                        end
                    end
                    allsubG = allsubG';
                    clear irow ii j jj subsubG subsubgroup subgroups igroupnum
                    
                    alligroup = {};
                    for ii = 2:length(allselgroups)
                        alligroup = [alligroup;allselgroups{ii}];
                    end
                    clear ii
                    
                    TP = TP + length(intersect(alligroup,allsubG));
                    FP = FP + length(setdiff(alligroup,allsubG));
                    clear alligroup allsubG allselgroups
                end
            end
            clear allselnum
        end
        clear ig igroup idx
        TN = restGnum;
        
        if TP + FP == 0
            sumPrecision(iframe) = 1;
        else
            sumPrecision(iframe) = TP / (TP + FP);
        end
        if TP + FN == 0
            sumRecall(iframe) = 1;
        else
            sumRecall(iframe) = TP / (TP + FN);
        end
        sumF1(iframe) = 2 / (1/sumPrecision(iframe) + 1/sumRecall(iframe));
        sumAcc(iframe) = (TP + TN) / (TP + TN + FP + FN);
    end
    clear TP TN FP FN
    clear subG preG selG restGnum
    
    sumAcc(bugtrial) = NaN;
    sumF1(bugtrial) = NaN;
    sumPrecision(bugtrial) = NaN;
    sumRecall(bugtrial) = NaN;
    
    F1(l+1,:)=sumF1;
    disp(['thr = ' num2str(0.01*l) ', F1 = ' num2str(nanmean(sumF1))]);
    
    Precision(l+1,:) = sumPrecision;
    Recall(l+1,:) = sumRecall;