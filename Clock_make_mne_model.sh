#!/bin/bash
export SUBJECTS_DIR=/data/Luna1/Multimodal/Clock
set -xe
# this is the script that will process anatomical MRI data (processed by freesurfer)
# to create source space for MNE analyses.

[ -z "$1" ] && echo "no subject given as first argument to $0!" && exit 1
[ ! -d "$SUBJECTS_DIR/$1" ] && echo "$SUBJECTS_DIR/$1 DNE" && exit 1

# only parameter is the subject name
cd $SUBJECTS_DIR
mne_setup_mri --subject $1 --overwrite

# creates source space containing dipole locations and orientations
mne_setup_source_space --subject $1 --spacing 7 --overwrite 

# creates the boundary-element model using the Wtershed algorithm
mne_watershed_bem --subject $1 --atlas --overwrite

cd  $SUBJECTS_DIR/$1/bem
cp watershed/$1_inner_skull_surface inner_skull.surf
cp watershed/$1_outer_skull_surface outer_skull.surf
cp watershed/$1_outer_skin_surface outer_skin.surf

# computes the geometry information for BEM
mne_setup_forward_model --subject $1 --surf --ico 4 --homog
# --homog   use homogeneuos shell, since we only have MEG data

# Create high-density head model for co-registration
mkheadsurf -subjid $1 -srcvol T1.mgz
mne_surf2bem --surf $SUBJECTS_DIR/$1/surf/lh.seghead --id 4 --check --fif $SUBJECTS_DIR/$1/bem/$1-head-dense.fif
											#seghead for old version
cd  $SUBJECTS_DIR/$1/bem
mv $1-head.fif $1-head-sparse.fif
ln $1-head-dense.fif $1-head.fif

cd $SUBJECTS_DIR

#run transformation to fsaverage
mne_make_morph_maps --from ${1} --to fsaverage --redo
