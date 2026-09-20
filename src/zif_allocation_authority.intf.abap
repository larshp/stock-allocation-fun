INTERFACE zif_allocation_authority PUBLIC.

  "! <p class="shorttext synchronized">Refuse to allocate in a plant the user may not touch</p>
  "!
  "! Behind an interface so the check can be exercised in a test, and so a site
  "! that guards allocation with its own authorization object can swap it.
  "!
  "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">User may not allocate in this plant</p>
  METHODS check_plant
    IMPORTING
      iv_werks TYPE mard-werks
    RAISING
      zcx_allocation.

ENDINTERFACE.
