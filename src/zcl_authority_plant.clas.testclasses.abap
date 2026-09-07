CLASS ltcl_authority_plant DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_cut TYPE REF TO zif_allocation_authority.

    METHODS setup.
    METHODS authorised_user_passes FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_authority_plant IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_authority_plant( ).
  ENDMETHOD.

  METHOD authorised_user_passes.

    " open-abap answers every AUTHORITY-CHECK with granted, so this covers the
    " statement itself but not the refusal branch, see ANOMALIES.md. What
    " happens when the check refuses is covered against a double in
    " ZCL_ALLOCATION_SERVICE, which is where it changes behaviour.
    mo_cut->check_plant( c_werks ).

  ENDMETHOD.

ENDCLASS.
