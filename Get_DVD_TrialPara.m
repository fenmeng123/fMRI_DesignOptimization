function TrialPara=Get_DVD_TrialPara(EDTDVD_Option)

if nargin <1
    TrialPara=EDTDVD_GetTrialPara();
else
    % exp_paraset_ERDT
    TrialPara=EDTDVD_GetTrialPara(EDTDVD_Option);
end
TrialPara.TrialOnset=cumsum(TrialPara.FixDura+TrialPara.CuePhaseDura+TrialPara.DecisionDura);
TrialPara.TrialOnset(2:end)=TrialPara.TrialOnset(1:end-1);
TrialPara.TrialOnset(1)=0;


