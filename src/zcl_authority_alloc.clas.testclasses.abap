CLASS ltcl_authority_alloc DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    METHODS a_change_is_checked FOR TESTING RAISING cx_static_check.
    METHODS a_display_is_checked FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_authority_alloc IMPLEMENTATION.

  METHOD a_change_is_checked.

    " open-abap answers every AUTHORITY-CHECK with granted, so this covers the
    " statement itself but not the refusal branch, see ANOMALIES.md. What
    " happens when the check refuses is covered against a double in
    " ZCL_ALLOCATION_SERVICE, which is where it changes behaviour.
    DATA(lo_cut) = CAST zif_allocation_authority( NEW zcl_authority_alloc( ) ).

    lo_cut->check_plant( c_werks ).

  ENDMETHOD.

  METHOD a_display_is_checked.

    DATA(lo_cut) = CAST zif_allocation_authority( NEW zcl_authority_alloc(
      zcl_authority_alloc=>c_activity_display ) ).

    lo_cut->check_plant( c_werks ).

  ENDMETHOD.

ENDCLASS.
