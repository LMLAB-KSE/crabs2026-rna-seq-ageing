# Instructor notes

The repository is organized by topic rather than by a fixed timetable. For a
three-hour workshop, a practical division is environment setup and orientation,
selected bulk QC plus DE, then Seurat exploration plus pseudo-bulk DE.

Do not try to run every line live. The retrieval and metadata scripts establish
where data come from, while checkpoints let teaching start at QC or DE.

## Suggested emphasis

- Let participants identify structure in the senescence PCA before naming the
  hidden researcher batch.
- Spend time on the DESeq2 design formula and reference level.
- In the ovarian analysis, make the experimental unit explicit: mice are
  biological replicates; cells are observations nested within mice.
- Ask participants to predict naive versus pseudo-bulk results before running
  the comparison.
- Treat GO enrichment as optional material if time remains.

## Branches

`main` is the complete tutorial. `exercises` replaces selected expressions with
`YOUR_CODE_HERE`, while preserving all discussion prompts. Update and test
`main` first, then port corresponding changes to `exercises`.
