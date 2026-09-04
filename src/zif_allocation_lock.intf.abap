INTERFACE zif_allocation_lock PUBLIC.

  "! <p class="shorttext synchronized">Claim a material in a plant for this run</p>
  "!
  "! Two runs working on the same material at the same time would both read the
  "! same available stock and both give it away.
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Somebody else has it</p>
  METHODS acquire
    IMPORTING
      iv_matnr TYPE mard-matnr
      iv_werks TYPE mard-werks
    RAISING
      zcx_allocation.

  "! <p class="shorttext synchronized">Give the material back</p>
  "!
  "! Never fails. Releasing a lock that is not held is not worth reporting, and
  "! this runs on the way out of a run that may already be failing.
  "!
  "! @parameter iv_matnr | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
  METHODS release
    IMPORTING
      iv_matnr TYPE mard-matnr
      iv_werks TYPE mard-werks.

ENDINTERFACE.
