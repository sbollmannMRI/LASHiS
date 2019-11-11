#!/bin/bash
#FS Long, FS XS, ASHS XS, LASHiS, and Diet LASHiS Absolute difference between 2/3
#DICE overlaps between them.
#Thomas Shaw
# 7/2/19

eval=/data/lfs2/software/tools/EvaluateSegmentation/EvaluateSegmentation
evals="-use DICE,ICCORR,VOLSMTY,MUTINF"
base_dir=/data/fasttemp/uqtshaw/tomcat/data/derivatives/
mkdir $base_dir/4_long_ashs/experiment_one/V4
dir=$base_dir/4_long_ashs/experiment_one/V4


<<EOF

for subjName in `cat /data/fasttemp/uqtshaw/tomcat/data/subjnames.csv ` ; do
    #similarity metrics
    #ASHS
    for method in LASHiS Diet_LASHiS ; do 
	for side in left right ; do
	 
	    # register the outputs to template space
	    antsApplyTransforms -d 3 -i ${base_dir}/5_LASHiS/${subjName}_LASHiS/${method}/${side}SSTLabelsWarpedTo1.nii.gz -o ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo1WarpedToSST.nii.gz -r ${base_dir}/5_LASHiS/${subjName}_LASHiSSingleSubjectTemplate/T_template1_rescaled.nii.gz -t ${base_dir}/5_LASHiS/${subjName}_LASHiS/LASHiS/JLF_label_output/${side}_SST_tse_native_chunk_${side}_1_0GenericAffine.mat -t ${base_dir}/5_LASHiS/${subjName}_LASHiS/LASHiS/JLF_label_output/${side}_SST_tse_native_chunk_${side}_1_1Warp.nii.gz
	    antsApplyTransforms -d 3 -i ${base_dir}/5_LASHiS/${subjName}_LASHiS/${method}/${side}SSTLabelsWarpedTo2.nii.gz -o ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo2WarpedToSST.nii.gz -r ${base_dir}/5_LASHiS/${subjName}_LASHiSSingleSubjectTemplate/T_template1_rescaled.nii.gz -t ${base_dir}/5_LASHiS/${subjName}_LASHiS/LASHiS/JLF_label_output/${side}_SST_tse_native_chunk_${side}_2_0GenericAffine.mat -t ${base_dir}/5_LASHiS/${subjName}_LASHiS/LASHiS/JLF_label_output/${side}_SST_tse_native_chunk_${side}_2_1Warp.nii.gz
	    #Threshold out the subfields
	    for ses in 1 2 ; do
		for subf in 1 2 3 4 8 ; do 
		    fslmaths ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST.nii.gz -thr ${subf} -uthr ${subf} ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST_${subf}.nii.gz
		    fslmaths ${base_dir}/5_LASHiS/${subjName}_LASHiS/${method}/${side}SSTLabelsWarpedTo${ses}.nii.gz -thr ${subf} -uthr ${subf} ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}_${subf}.nii.gz
		done
		mv ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST_1.nii.gz ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST_CA1.nii.gz 
		mv ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST_3.nii.gz ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST_DG.nii.gz
		mv ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST_8.nii.gz ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST_SUB.nii.gz
		fslmaths ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST_2.nii.gz -add ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST_4.nii.gz ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}WarpedToSST_CA2.nii.gz 
		#non warped for volsim
		mv ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}_1.nii.gz ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}_CA1.nii.gz 
		mv ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}_3.nii.gz ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}_DG.nii.gz
		mv ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}_8.nii.gz ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}_SUB.nii.gz
		fslmaths ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}_2.nii.gz -add ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}_4.nii.gz ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo${ses}_CA2.nii.gz
	
	    done
	    for subf in CA1 CA2 DG SUB ; do 	
		#LASHiS test retest
		$eval ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo1WarpedToSST_${subf}.nii.gz ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo2WarpedToSST_${subf}.nii.gz -use DICE -xml $dir/${subjName}_${method}_${side}_${subf}_test_retest.xml &

		##need to flirt TP 2 and 3 tog. (no resample) to get same size image for volsim
		
		flirt -in ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo1_${subf}.nii.gz -ref ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo2_${subf}.nii.gz -applyxfm -usesqform -out ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo1_${subf}_tp_2_sqform.nii.gz

		$eval ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo1_${subf}_tp_2_sqform.nii.gz ${dir}/${subjName}${method}${side}SSTLabelsWarpedTo2_${subf}.nii.gz -use VOLSMTY -xml $dir/${subjName}_${method}_${side}_${subf}_test_retest_VOLSIM.xml &
	    done
	done
    done
done

EOF


#Concat results
for index in "Dice" "Volume" ; do	
    #ASHS
    for subjName in `cat /data/fasttemp/uqtshaw/tomcat/data/subjnames.csv ` ; do
	for side in left right ; do
	    for subf in CA1 CA2 DG SUB ; do
		cat $dir/${subjName}_LASHiS_${side}_${subf}_test_retest.xml | grep ${index} | sed 's/[^0-9.]*//g' >> $dir/${index}LASHiS_${side}_${subf}_concat.txt
		cat $dir/${subjName}_Diet_LASHiS_${side}_${subf}_test_retest.xml | grep ${index} | sed 's/[^0-9.]*//g' >> $dir/${index}Diet_LASHiS_${side}_${subf}_concat.txt
		cat $dir/${subjName}_LASHiS_${side}_${subf}_test_retest_VOLSIM.xml | grep ${index} | sed 's/[^0-9.]*//g' >> $dir/${index}LASHiS_${side}_${subf}_concat_VOLSIM.txt
		cat $dir/${subjName}_Diet_LASHiS_${side}_${subf}_test_retest_VOLSIM.xml | grep ${index} | sed 's/[^0-9.]*//g' >> $dir/${index}Diet_LASHiS_${side}_${subf}_concat_VOLSIM.txt
		
	    done
	done
    done

done
#volume paste
for thingo in LASHiS Diet_LASHiS ; do
    paste $dir/Volume${thingo}_left_CA1_concat_VOLSIM.txt $dir/Volume${thingo}_left_CA2_concat_VOLSIM.txt $dir/Volume${thingo}_left_DG_concat_VOLSIM.txt $dir/Volume${thingo}_left_SUB_concat_VOLSIM.txt $dir/Volume${thingo}_right_CA1_concat_VOLSIM.txt $dir/Volume${thingo}_right_CA2_concat_VOLSIM.txt $dir/Volume${thingo}_right_DG_concat_VOLSIM.txt $dir/Volume${thingo}_right_SUB_concat_VOLSIM.txt | column -s $'\t' -t >> ${dir}/volume_${thingo}_final.txt

    paste $dir/Dice${thingo}_left_CA1_concat.txt $dir/Dice${thingo}_left_CA2_concat.txt $dir/Dice${thingo}_left_DG_concat.txt $dir/Dice${thingo}_left_SUB_concat.txt $dir/Dice${thingo}_right_CA1_concat.txt $dir/Dice${thingo}_right_CA2_concat.txt $dir/Dice${thingo}_right_DG_concat.txt $dir/Dice${thingo}_right_SUB_concat.txt | column -s $'\t' -t >> ${dir}/dice_${thingo}_final.txt
done
#fs and ashsxs were right the first time, don't need new results.
for thingo in ASHS_Xs FS_Long FS_Xs ; do
    paste /data/fasttemp/uqtshaw/tomcat/data/derivatives/4_long_ashs/experiment_one/Volume${thingo}_left_CA1_concat.txt /data/fasttemp/uqtshaw/tomcat/data/derivatives/4_long_ashs/experiment_one/Volume${thingo}_left_CA2_concat.txt /data/fasttemp/uqtshaw/tomcat/data/derivatives/4_long_ashs/experiment_one/Volume${thingo}_left_DG_concat.txt /data/fasttemp/uqtshaw/tomcat/data/derivatives/4_long_ashs/experiment_one/Volume${thingo}_left_SUB_concat.txt /data/fasttemp/uqtshaw/tomcat/data/derivatives/4_long_ashs/experiment_one/Volume${thingo}_right_CA1_concat.txt /data/fasttemp/uqtshaw/tomcat/data/derivatives/4_long_ashs/experiment_one/Volume${thingo}_right_CA2_concat.txt /data/fasttemp/uqtshaw/tomcat/data/derivatives/4_long_ashs/experiment_one/Volume${thingo}_right_DG_concat.txt /data/fasttemp/uqtshaw/tomcat/data/derivatives/4_long_ashs/experiment_one/Volume${thingo}_right_SUB_concat.txt | column -s $'\t' -t >> ${dir}/volume_${thingo}_final.txt
done

    #This is if you want to throw it all together (not useful)
    
    #for side in left right ; do
#	for subf in CA1 CA2 DG SUB ; do		
#	    cat $dir/${index}LASHiS_${side}_${subf}_concat.txt >> ${index}ALL_${side}_${subf}.txt
#	    cat $dir/${index}Diet_LASHiS_${side}_${subf}_concat.txt >> ${index}ALL_${side}_${subf}.txt	
	    #cat $dir/${index}LASHiS_${side}_${subf}_concat_VOLSIM.txt >> ${index}ALL_${side}_${subf}_VOLSIM.txt
	    #cat $dir/${index}Diet_LASHiS_${side}_${subf}_concat_VOLSIM.txt >> ${index}ALL_${side}_${subf}_VOLSIM.txt
#	done
#    done

    #paste ${index}ALL_left_CA1.txt ${index}ALL_left_CA2.txt ${index}ALL_left_DG.txt ${index}ALL_left_SUB.txt ${index}ALL_right_CA1.txt ${index}ALL_right_CA2.txt ${index}ALL_right_DG.txt ${index}ALL_right_SUB.txt | column -s $'\t' -t >> ${index}_final.txt
    #paste ${index}ALL_left_CA1.txt ${index}ALL_left_CA2.txt ${index}ALL_left_DG.txt ${index}ALL_left_SUB.txt ${index}ALL_right_CA1.txt ${index}ALL_right_CA2.txt ${index}ALL_right_DG.txt ${index}ALL_right_SUB.txt | column -s $'\t' -t >> $dir/${index}_final.txt
