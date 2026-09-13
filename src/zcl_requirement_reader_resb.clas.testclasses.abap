CLASS ltcl_requirement_reader_resb DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_resb_tt TYPE STANDARD TABLE OF resb WITH DEFAULT KEY.

    CLASS-DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut TYPE REF TO zif_requirement_reader.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.

    METHODS given_requirement
      IMPORTING
        iv_rsnum TYPE resb-rsnum
        iv_rspos TYPE resb-rspos
        iv_bdmng TYPE menge_d DEFAULT 0
        iv_enmng TYPE menge_d DEFAULT 0
        iv_bdter TYPE d OPTIONAL
        iv_xloek TYPE resb-xloek OPTIONAL
        iv_kzear TYPE resb-kzear OPTIONAL
        iv_matnr TYPE matnr DEFAULT 'MAT-1'
        iv_werks TYPE werks_d DEFAULT '1000'.

    METHODS when_requirements_are_read
      RETURNING
        VALUE(rt_requirements) TYPE zif_requirement_reader=>ty_requirement_tt.

    METHODS reads_open_requirements     FOR TESTING.
    METHODS subtracts_withdrawn_qty     FOR TESTING.
    METHODS skips_deleted_items         FOR TESTING.
    METHODS skips_issued_items          FOR TESTING.
    METHODS skips_fully_withdrawn       FOR TESTING.
    METHODS ignores_other_material      FOR TESTING.
    METHODS builds_id_from_key          FOR TESTING.
    METHODS sorts_by_requirement_date   FOR TESTING.
ENDCLASS.


CLASS ltcl_requirement_reader_resb IMPLEMENTATION.

  METHOD class_setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'RESB' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
    ENDIF.
  ENDMETHOD.

  METHOD setup.
    mo_environment->clear_doubles( ).
    mo_cut = NEW zcl_requirement_reader_resb( ).
  ENDMETHOD.

  METHOD given_requirement.
    DATA lv_date TYPE d.
    DATA ls_resb TYPE resb.

    lv_date = iv_bdter.
    IF lv_date IS INITIAL.
      lv_date = '20260101'.
    ENDIF.

    ls_resb-mandt = sy-mandt.
    ls_resb-rsnum = iv_rsnum.
    ls_resb-rspos = iv_rspos.
    ls_resb-rsart = '1'.
    ls_resb-matnr = iv_matnr.
    ls_resb-werks = iv_werks.
    ls_resb-lgort = '0001'.
    ls_resb-bdmng = iv_bdmng.
    ls_resb-enmng = iv_enmng.
    ls_resb-bdter = lv_date.
    ls_resb-xloek = iv_xloek.
    ls_resb-kzear = iv_kzear.

    mo_environment->insert_test_data( VALUE ty_resb_tt( ( ls_resb ) ) ).
  ENDMETHOD.

  METHOD when_requirements_are_read.
    rt_requirements = mo_cut->read_requirements( iv_matnr = 'MAT-1'
                                                 iv_werks = '1000' ).
  ENDMETHOD.

  METHOD reads_open_requirements.
    given_requirement( iv_rsnum = '0000000001'
                       iv_rspos = '0001'
                       iv_bdmng = '10' ).
    given_requirement( iv_rsnum = '0000000002'
                       iv_rspos = '0001'
                       iv_bdmng = '4' ).

    DATA(lt_requirements) = when_requirements_are_read( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_requirements )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_requirements[ 1 ]-requested_qty exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_requirements[ 1 ]-requested_date exp = '20260101' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_requirements[ 1 ]-priority exp = 1 ).
  ENDMETHOD.

  METHOD subtracts_withdrawn_qty.
    given_requirement( iv_rsnum = '0000000001'
                       iv_rspos = '0001'
                       iv_bdmng = '10'
                       iv_enmng = '4' ).

    DATA(lt_requirements) = when_requirements_are_read( ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_requirements[ 1 ]-requested_qty exp = '6' ).
  ENDMETHOD.

  METHOD skips_deleted_items.
    given_requirement( iv_rsnum = '0000000001'
                       iv_rspos = '0001'
                       iv_bdmng = '10'
                       iv_xloek = 'X' ).
    given_requirement( iv_rsnum = '0000000002'
                       iv_rspos = '0001'
                       iv_bdmng = '5' ).

    DATA(lt_requirements) = when_requirements_are_read( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_requirements )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_requirements[ 1 ]-requested_qty exp = '5' ).
  ENDMETHOD.

  METHOD skips_issued_items.
    given_requirement( iv_rsnum = '0000000001'
                       iv_rspos = '0001'
                       iv_bdmng = '10'
                       iv_kzear = 'X' ).

    DATA(lt_requirements) = when_requirements_are_read( ).

    cl_abap_unit_assert=>assert_initial( act = lt_requirements ).
  ENDMETHOD.

  METHOD skips_fully_withdrawn.
    given_requirement( iv_rsnum = '0000000001'
                       iv_rspos = '0001'
                       iv_bdmng = '5'
                       iv_enmng = '5' ).

    DATA(lt_requirements) = when_requirements_are_read( ).

    cl_abap_unit_assert=>assert_initial( act = lt_requirements ).
  ENDMETHOD.

  METHOD ignores_other_material.
    given_requirement( iv_rsnum = '0000000001'
                       iv_rspos = '0001'
                       iv_bdmng = '10'
                       iv_matnr = 'OTHER' ).

    DATA(lt_requirements) = when_requirements_are_read( ).

    cl_abap_unit_assert=>assert_initial( act = lt_requirements ).
  ENDMETHOD.

  METHOD builds_id_from_key.
    given_requirement( iv_rsnum = '0000000001'
                       iv_rspos = '0007'
                       iv_bdmng = '1' ).

    DATA(lt_requirements) = when_requirements_are_read( ).

    cl_abap_unit_assert=>assert_equals( act = lt_requirements[ 1 ]-id
                                        exp = '00000000010007' ).
  ENDMETHOD.

  METHOD sorts_by_requirement_date.
    given_requirement( iv_rsnum = '0000000001'
                       iv_rspos = '0001'
                       iv_bdmng = '1'
                       iv_bdter = '20261231' ).
    given_requirement( iv_rsnum = '0000000002'
                       iv_rspos = '0001'
                       iv_bdmng = '1'
                       iv_bdter = '20260101' ).

    DATA(lt_requirements) = when_requirements_are_read( ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_requirements[ 1 ]-requested_date exp = '20260101' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_requirements[ 2 ]-requested_date exp = '20261231' ).
  ENDMETHOD.

ENDCLASS.
