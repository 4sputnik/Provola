#!/bin/bash
####################################################################################################################
#####       Bash script that looks for T1-3D mri dicoms and converts to nii and mgz                            #####
####################################################################################################################
#
#recommendations: -only valid for T1 3D, otherwise need to specify other names and conditions
#
              
#----user inputs-------------------------------

homerun=$(pwd)           #starting folder
countz=10                #max number of spaces to be replaced
depth=1000               #subdirectories depth

#----------------------------------------------
mkdir MGZ_Folder

while [ $countz != 0 ] 
do 
  echo $countz
  find -type d -execdir rename 's/ /_/' '{}' \+
  countz=$(( $countz - 1))
done

echo 'rename complete'

dirarray=($(find -maxdepth $depth -type d -iname *t1*))

for i_dir in ${dirarray[@]} 
do
  echo $i_dir 
  cd $i_dir
  for file in *                   #cycle for conversion DICOM->NIFTI->MGZ
  do
    if [[ $file == *.dcm ]]
    then                
      check3D=$(dicom_hdr $file | grep MR\ Acquisition\ Type\ //3D)
      lengthcheck=$(echo $check3D | awk '{print length}')
      if [ $lengthcheck != 0 ]
      then
        Date_long=$(dicom_hdr $file | grep ID\ Image\ Date)
        Date_medium=$(echo $Date_long | awk '{print $9}')
        Date=${Date_medium:6}
        ID_long=$(dicom_hdr $file | grep PAT\ Patient\ ID)
        ID_medium=$(echo $ID_long | awk '{print $9}')
        ID=${ID_medium:4}
        Acq_Type_long=$(dicom_hdr $file | grep ID\ Series\ Description)
        Acq_Type_medium=$(echo $Acq_Type_long | awk '{print $9}')
        Acq_Type=${Acq_Type_medium:13}
        filenome=$ID\_$Date\_$Acq_Type
        echo $filenome                             
        to3d -quit_on_err -prefix $filenome *.dcm
        3dAFNItoNIFTI $filenome+orig -prefix *.nii
        fslreorient2std $filenome.nii STD\_ORNT\_$filenome.nii
        rm $filenome*
        mri_convert STD\_ORNT\_$filenome.nii.gz $filenome.mgz
        mv $filenome.mgz $homerun/MGZ_Folder
        rm *.nii.gz
        break
      fi
    fi
  done
  cd $homerun
done
