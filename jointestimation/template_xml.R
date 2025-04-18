# Load necessary libraries
# script adapted by code from Leke Lyu
# LD 2025-02

library(dplyr)
library(magrittr)
library(stringr)
library(lubridate)
library(ape)
library(seqinr)
# This script creates XMLs to run a jointly estimated DTA given the following:
# FASTA files for each cluster of intrest
# Empricial tree distribtuion files (.tree nexus outputs from BEAST) for each cluster
# metadata file which contains metadata of interest for all taxa in the analysis 

# set working directory
workdir <- "~/Downloads/test_beast/"
setwd(workdir)

# read in metadata files
urb_rur_meta <-  read.csv("test_joint_sars2_urbrur_dta/parsed_sequences_with_taxon.csv")

# specify folder where empirical trees are and inf
treFolder <- "tre"
nameOfColumnStoringID <- "taxon_name"
nameOfColumnStoringDecimalDate <- "date"
nameOfColumnStoringTrait <- "urb_rur"

# make the tree list which has each cluster and its corresponding tip.lables
# make a seperate tip.list which contains the list of taxon lables 

# Function to extract taxon names from a FASTA file
get_taxa_list <- function(file) {
  taxa_names <- names(read.fasta(file))
  list(tip.label = taxa_names)   # Extract taxon labels (sequence names)
}

#  folder path to fasta files for each cluster
folder_path <- "test_joint_sars2_urbrur_dta/"
# Get list of FASTA files in the folder
fasta_files <- list.files(folder_path, pattern = "\\.fasta$", full.names = TRUE)

# Read taxa names from each FASTA file and store in a named list
newtreList <- lapply(fasta_files, get_taxa_list)
names(newtreList) <- basename(fasta_files)  # Use file names as list names
tipList <- newtreList

# Get the specific names for the clusters based on the list from fastas
clusternames <- sub("\\.fasta$", "", names(newtreList))

clusterID <- 1:length(newtreList)
Start <- 1 # 1
Stop <- length(clusterID) # length(clusterID) # 3

#specifcy chainlenght you want
chainLength <- "100000000"
logEvery <- "10000"

# Data preprocessing

# Open the output file in write mode
output_file <- paste0(workdir, "/output.xml")
fileConn <- file(output_file, "w")
tre_path <- file.path(workdir, treFolder)
if (!dir.exists(tre_path)) {
  dir.create(tre_path)
}

# Write the initial beast version tag
write('<beast version="1.10.4">\n', fileConn)

if (length(tipList) == length(newtreList)) {
  
  # Insert taxa blocks
  for (j in Start:Stop) {
    xml_string <- paste0('\n\t<taxa id="taxa_', clusternames[j], '">\n')
    
    tre <- newtreList[[j]]
    taxaLabel <- tre$tip.label
    meta <- urb_rur_meta %>% filter(get(nameOfColumnStoringID) %in% taxaLabel) 
    
    for (k in 1:nrow(meta)) {
      xml_string <- paste0(xml_string, '\t\t<taxon id="', meta[k, nameOfColumnStoringID], '">\n')
      xml_string <- paste0(xml_string, '\t\t\t<date value="', meta[k, nameOfColumnStoringDecimalDate], '" direction="forwards" units="years"/>\n')
      xml_string <- paste0(xml_string, '\t\t\t<attr name="location">\n')
      xml_string <- paste0(xml_string, '\t\t\t\t', meta[k, nameOfColumnStoringTrait], '\n')
      xml_string <- paste0(xml_string, '\t\t\t</attr>\n')
      xml_string <- paste0(xml_string, '\t\t</taxon>\n')
    }
    
    xml_string <- paste0(xml_string, '\t</taxa>\n')
    write(xml_string, fileConn, append = TRUE)
  }
  
  # Insert alignment blocks
  for (j in Start:Stop) {
    xml_string <- paste0('\n\t<alignment id="alignment_', clusternames[j], '" dataType="nucleotide">\n')
    
    tre <- newtreList[[j]]
    taxaLabel <- tre$tip.label
    
    for (k in 1:length(taxaLabel)) {
      xml_string <- paste0(xml_string, '\t\t<sequence>\n')
      xml_string <- paste0(xml_string, '\t\t\t<taxon idref="', taxaLabel[k], '"/>\n')
      xml_string <- paste0(xml_string, '\t\t\tNNNN\n')
      xml_string <- paste0(xml_string, '\t\t</sequence>\n')
    }
    
    xml_string <- paste0(xml_string, '\t</alignment>\n')
    write(xml_string, fileConn, append = TRUE)
  }
  
  # Insert pattern blocks
  for (j in Start:Stop) {
    xml_string <- paste0('\n\t<patterns id="patterns_', clusternames[j], '" from="1" strip="false">\n')
    xml_string <- paste0(xml_string, '\t\t<alignment idref="alignment_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t</patterns>\n')
    write(xml_string, fileConn, append = TRUE)
  }
  
  # Insert tree blocks
  for (j in Start:Stop) {
    #edit the section after filename= to correspond to the directory where all empirical trees are being kept
    xml_string <- paste0('\n\t<empiricalTreeDistributionModel id="treeModel_', clusternames[j], '" fileName="', 'tre/', clusternames[j], '.trees">\n')
    tre <- newtreList[[j]]
    path <- paste0(tre_path, "/Clade_", clusternames[j], ".tre")
    xml_string <- paste0(xml_string, '\t\t<taxa idref="taxa_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t</empiricalTreeDistributionModel>\n')
    write(xml_string, fileConn, append = TRUE)
  }
  
  # Discrete trait model
  traits <- urb_rur_meta[, nameOfColumnStoringTrait] %>% unique()
  clear <- traits[traits != "Unknown"]
  ambiguous <- "Unknown"
  xml_string <- '\n\t<generalDataType id="location.dataType">\n'
  for (x in clear) {
    xml_string <- paste0(xml_string, '\t\t<state code="', x, '"/>\n')
  }
  xml_string <- paste0(xml_string, '\t\t<ambiguity code="', ambiguous, '" states="', paste(clear, collapse = " "), '"/>\n')
  xml_string <- paste0(xml_string, '\t</generalDataType>\n')
  write(xml_string, fileConn, append = TRUE)
  
  # Insert location.pattern blocks
  for (j in Start:Stop) {
    xml_string <- paste0('\n\t<attributePatterns id="location.pattern_', clusternames[j], '" attribute="location">\n')
    xml_string <- paste0(xml_string, '\t\t<taxa idref="taxa_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t\t<generalDataType idref="location.dataType"/>\n')
    xml_string <- paste0(xml_string, '\t</attributePatterns>\n')
    write(xml_string, fileConn, append = TRUE)
  }
  
  # Insert strict clock branch rates block
  xml_string <- '\n\t<strictClockBranchRates id="location.branchRates">\n'
  xml_string <- paste0(xml_string, '\t\t<rate>\n')
  xml_string <- paste0(xml_string, '\t\t\t<parameter id="location.clock.rate" value="1.0" lower="0.0"/>\n')
  xml_string <- paste0(xml_string, '\t\t</rate>\n')
  xml_string <- paste0(xml_string, '\t</strictClockBranchRates>\n')
  write(xml_string, fileConn, append = TRUE)
  
  # Insert rateStatistic blocks
  for (j in Start:Stop) {
    xml_string <- paste0('\n\t<rateStatistic id="location.meanRate_', clusternames[j], '" name="location.meanRate_', clusternames[j], '" mode="mean" internal="true" external="true">\n')
    xml_string <- paste0(xml_string, '\t\t<treeModel idref="treeModel_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t\t<strictClockBranchRates idref="location.branchRates"/>\n')
    xml_string <- paste0(xml_string, '\t</rateStatistic>\n')
    write(xml_string, fileConn, append = TRUE)
  }
  
  # Insert asymmetric CTMC models block
  xml_string <- '\n\t<generalSubstitutionModel id="location.model" randomizeIndicator="false">\n'
  xml_string <- paste0(xml_string, '\t\t<generalDataType idref="location.dataType"/>\n')
  xml_string <- paste0(xml_string, '\t\t<frequencies>\n')
  xml_string <- paste0(xml_string, '\t\t\t<frequencyModel id="location.frequencyModel" normalize="true">\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<generalDataType idref="location.dataType"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<frequencies>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t\t<parameter id="location.frequencies" dimension="', length(clear),'"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t</frequencies>\n')
  xml_string <- paste0(xml_string, '\t\t\t</frequencyModel>\n')
  xml_string <- paste0(xml_string, '\t\t</frequencies>\n')
  xml_string <- paste0(xml_string, '\t\t<!-- rates and indicators -->\n')
  xml_string <- paste0(xml_string, '\t\t<rates>\n')
  xml_string <- paste0(xml_string, '\t\t\t<parameter id="location.rates" dimension="', length(clear)*(length(clear)-1),'" value="1.0" lower="0.0"/>\n')
  xml_string <- paste0(xml_string, '\t\t</rates>\n')
  xml_string <- paste0(xml_string, '\t\t<rateIndicator>\n')
  xml_string <- paste0(xml_string, '\t\t\t<parameter id="location.indicators" dimension="', length(clear)*(length(clear)-1),'" value="1.0"/>\n')
  xml_string <- paste0(xml_string, '\t\t</rateIndicator>\n')
  xml_string <- paste0(xml_string, '\t</generalSubstitutionModel>\n')
  write(xml_string, fileConn, append = TRUE)
  
  # Insert sumStatistic blocks
  xml_string <- '\n\t<sumStatistic id="location.nonZeroRates" elementwise="true">\n'
  xml_string <- paste0(xml_string, '\t\t<parameter idref="location.indicators"/>\n')
  xml_string <- paste0(xml_string, '\t</sumStatistic>\n')
  write(xml_string, fileConn, append = TRUE)
  
  # Insert productStatistic blocks
  xml_string <- '\n\t<productStatistic id="location.actualRates" elementwise="false">\n'
  xml_string <- paste0(xml_string, '\t\t<parameter idref="location.indicators"/>\n')
  xml_string <- paste0(xml_string, '\t\t<parameter idref="location.rates"/>\n')
  xml_string <- paste0(xml_string, '\t</productStatistic>\n')
  write(xml_string, fileConn, append = TRUE)
  
  # Insert siteModel blocks
  xml_string <- '\n\t<siteModel id="location.siteModel">\n'
  xml_string <- paste0(xml_string, '\t\t<substitutionModel>\n')
  xml_string <- paste0(xml_string, '\t\t\t<generalSubstitutionModel idref="location.model"/>\n')
  xml_string <- paste0(xml_string, '\t\t</substitutionModel>\n')
  xml_string <- paste0(xml_string, '\t</siteModel>\n')
  write(xml_string, fileConn, append = TRUE)
  
  # Insert ancestralTreeLikelihood blocks
  for (j in Start:Stop) {
    xml_string <- paste0('\n\t<ancestralTreeLikelihood id="location.treeLikelihood_', clusternames[j], '" stateTagName="location.states" useUniformization="true" saveCompleteHistory="false" logCompleteHistory="false">\n')
    xml_string <- paste0(xml_string, '\t\t<attributePatterns idref="location.pattern_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t\t<treeModel idref="treeModel_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t\t<siteModel idref="location.siteModel"/>\n')
    xml_string <- paste0(xml_string, '\t\t<generalSubstitutionModel idref="location.model"/>\n')
    xml_string <- paste0(xml_string, '\t\t<strictClockBranchRates idref="location.branchRates"/>\n')
    xml_string <- paste0(xml_string, '\t\t<frequencyModel id="location.root.frequencyModel_', clusternames[j], '" normalize="true">\n')
    xml_string <- paste0(xml_string, '\t\t\t<generalDataType idref="location.dataType"/>\n')
    xml_string <- paste0(xml_string, '\t\t\t<frequencies>\n')
    xml_string <- paste0(xml_string, '\t\t\t\t<parameter id="location.root.frequencies_', clusternames[j], '" dimension="', length(clear),'"/>\n')
    xml_string <- paste0(xml_string, '\t\t\t</frequencies>\n')
    xml_string <- paste0(xml_string, '\t\t</frequencyModel>\n')
    xml_string <- paste0(xml_string, '\t</ancestralTreeLikelihood>\n')
    write(xml_string, fileConn, append = TRUE)
  }
  
  # Insert operators block
  xml_string <- paste0('\n\t<operators id="operators" optimizationSchedule="log">\n')
  xml_string <- paste0(xml_string, '\t\t<scaleOperator scaleFactor="0.75" weight="3">\n')
  xml_string <- paste0(xml_string, '\t\t\t<parameter idref="location.clock.rate"/>\n')
  xml_string <- paste0(xml_string, '\t\t</scaleOperator>\n')
  xml_string <- paste0(xml_string, '\t\t<scaleOperator scaleFactor="0.75" weight="15" scaleAllIndependently="true">\n')
  xml_string <- paste0(xml_string, '\t\t\t<parameter idref="location.rates"/>\n')
  xml_string <- paste0(xml_string, '\t\t</scaleOperator>\n')
  xml_string <- paste0(xml_string, '\t\t<bitFlipOperator weight="7">\n')
  xml_string <- paste0(xml_string, '\t\t\t<parameter idref="location.indicators"/>\n')
  xml_string <- paste0(xml_string, '\t\t</bitFlipOperator>\n')
  for (j in Start:Stop) {
    xml_string <- paste0(xml_string, '\t\t<deltaExchange delta="0.75" weight="1">\n')
    xml_string <- paste0(xml_string, '\t\t\t<parameter idref="location.root.frequencies_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t\t</deltaExchange>\n')
  }
  xml_string <- paste0(xml_string, '\t</operators>\n')
  write(xml_string, fileConn, append = TRUE)
  
  # Insert MCMC block with nested elements
  xml_string <- paste0('\n\t<mcmc id="mcmc" chainLength="', chainLength, '" autoOptimize="true" operatorAnalysis="All_clades.ops">\n')
  
  xml_string <- paste0(xml_string, '\t\t<joint id="joint">\n')
  xml_string <- paste0(xml_string, '\t\t\t<prior id="prior">\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<poissonPrior mean="1.0" offset="0.0">\n')
  xml_string <- paste0(xml_string, '\t\t\t\t\t<statistic idref="location.nonZeroRates"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t</poissonPrior>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<uniformPrior lower="0.0" upper="1.0">\n')
  xml_string <- paste0(xml_string, '\t\t\t\t\t<parameter idref="location.frequencies"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t</uniformPrior>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<cachedPrior>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t\t<gammaPrior shape="1.0" scale="1.0" offset="0.0">\n')
  xml_string <- paste0(xml_string, '\t\t\t\t\t\t<parameter idref="location.rates"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t\t</gammaPrior>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t\t<parameter idref="location.rates"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t</cachedPrior>\n')
  for (j in Start:Stop) {
    xml_string <- paste0(xml_string, '\t\t\t\t<ctmcScalePrior>\n')
    xml_string <- paste0(xml_string, '\t\t\t\t\t<ctmcScale>\n')
    xml_string <- paste0(xml_string, '\t\t\t\t\t\t<parameter idref="location.clock.rate"/>\n')
    xml_string <- paste0(xml_string, '\t\t\t\t\t</ctmcScale>\n')
    xml_string <- paste0(xml_string, '\t\t\t\t\t<treeModel idref="treeModel_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t\t\t\t</ctmcScalePrior>\n')
  }
  for (j in Start:Stop) {
    xml_string <- paste0(xml_string, '\t\t\t\t<uniformPrior lower="0.0" upper="1.0">\n')
    xml_string <- paste0(xml_string, '\t\t\t\t\t<parameter idref="location.root.frequencies_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t\t\t\t</uniformPrior>\n')
  }
  xml_string <- paste0(xml_string, '\t\t\t\t<strictClockBranchRates idref="location.branchRates"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<generalSubstitutionModel idref="location.model"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t</prior>\n')
  xml_string <- paste0(xml_string, '\t\t\t<likelihood id="likelihood">\n')
  for (j in Start:Stop) {
    xml_string <- paste0(xml_string, '\t\t\t\t<ancestralTreeLikelihood idref="location.treeLikelihood_', clusternames[j], '"/>\n')
  }
  xml_string <- paste0(xml_string, '\t\t\t</likelihood>\n')
  xml_string <- paste0(xml_string, '\t\t</joint>\n')
  
  xml_string <- paste0(xml_string, '\t\t<operators idref="operators"/>\n')
  
  xml_string <- paste0(xml_string, '\t\t<log id="screenLog" logEvery="', logEvery, '">\n')
  xml_string <- paste0(xml_string, '\t\t\t<column label="Joint" dp="4" width="12">\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<joint idref="joint"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t</column>\n')
  xml_string <- paste0(xml_string, '\t\t\t<column label="Prior" dp="4" width="12">\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<prior idref="prior"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t</column>\n')
  xml_string <- paste0(xml_string, '\t\t\t<column label="Likelihood" dp="4" width="12">\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<likelihood idref="likelihood"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t</column>\n')
  xml_string <- paste0(xml_string, '\t\t\t<column label="location.clock.rate" sf="6" width="12">\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<parameter idref="location.clock.rate"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t</column>\n')
  xml_string <- paste0(xml_string, '\t\t\t<column label="location.nonZeroRates" dp="0" width="6">\n')
  xml_string <- paste0(xml_string, '\t\t\t\t<sumStatistic idref="location.nonZeroRates"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t</column>\n')
  xml_string <- paste0(xml_string, '\t\t</log>\n')
  
  xml_string <- paste0(xml_string, '\t\t<log id="fileLog" logEvery="', logEvery, '" fileName="All_clades.log" overwrite="false">\n')
  xml_string <- paste0(xml_string, '\t\t\t<joint idref="joint"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t<prior idref="prior"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t<likelihood idref="likelihood"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t<parameter idref="location.clock.rate"/>\n')
  for (j in Start:Stop) {
    xml_string <- paste0(xml_string, '\t\t\t<rateStatistic idref="location.meanRate_', clusternames[j], '"/>\n')
  }
  xml_string <- paste0(xml_string, '\t\t\t<parameter idref="location.rates"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t<parameter idref="location.indicators"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t<sumStatistic idref="location.nonZeroRates"/>\n')
  xml_string <- paste0(xml_string, '\t\t\t<strictClockBranchRates idref="location.branchRates"/>\n')
  for (j in Start:Stop) {
    xml_string <- paste0(xml_string, '\t\t\t<ancestralTreeLikelihood idref="location.treeLikelihood_', clusternames[j], '"/>\n')
  }
  xml_string <- paste0(xml_string, '\t\t</log>\n')

  for (j in Start:Stop) {
    xml_string <- paste0(xml_string, '\t\t<logTree id="treeFileLog_', clusternames[j], '" logEvery="', logEvery, '" nexusFormat="true" fileName="Clade_', clusternames[j], '.trees" sortTranslationTable="true">\n')
    xml_string <- paste0(xml_string, '\t\t\t<treeModel idref="treeModel_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t\t\t<trait name="rate" tag="location.rate">\n')
    xml_string <- paste0(xml_string, '\t\t\t\t<strictClockBranchRates idref="location.branchRates"/>\n')
    xml_string <- paste0(xml_string, '\t\t\t</trait>\n')
    xml_string <- paste0(xml_string, '\t\t\t<joint idref="joint"/>\n')
    xml_string <- paste0(xml_string, '\t\t\t<trait name="location.states" tag="location">\n')
    xml_string <- paste0(xml_string, '\t\t\t\t<ancestralTreeLikelihood idref="location.treeLikelihood_', clusternames[j], '"/>\n')
    xml_string <- paste0(xml_string, '\t\t\t</trait>\n')
    xml_string <- paste0(xml_string, '\t\t</logTree>\n')
  }

  xml_string <- paste0(xml_string, '\t</mcmc>\n')
  write(xml_string, fileConn, append = TRUE)
  
  # Insert report block
  xml_string <- paste0('\n\t<report>\n')
  xml_string <- paste0(xml_string, '\t\t<property name="timer">\n')
  xml_string <- paste0(xml_string, '\t\t\t<mcmc idref="mcmc"/>\n')
  xml_string <- paste0(xml_string, '\t\t</property>\n')
  xml_string <- paste0(xml_string, '\t</report>\n')
  write(xml_string, fileConn, append = TRUE)
  
  # Close the XML
  write('\n</beast>\n', fileConn, append = TRUE)
  close(fileConn)
  
} else {
  stop("The length of clusternames does not match the number of phylo objects in newtreList.")
}

