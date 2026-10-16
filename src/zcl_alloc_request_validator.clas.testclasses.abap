CLASS ltcl_alloc_request_validator DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_request_validator.

    METHODS setup.

    METHODS request
      IMPORTING
        iv_matnr      TYPE matnr
        iv_werks      TYPE werks_d
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_request_validator=>ty_request.

    METHODS valid_request    FOR TESTING.
    METHODS empty_list       FOR TESTING.
    METHODS empty_material   FOR TESTING.
    METHODS empty_plant      FOR TESTING.
    METHODS zero_quantity    FOR TESTING.
    METHODS negative_quantity FOR TESTING.
    METHODS multiple_issues  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_request_validator IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_request_validator( ).
  ENDMETHOD.

  METHOD request.
    rs_row-matnr = iv_matnr.
    rs_row-werks = iv_werks.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD valid_request.
    DATA lt_requests TYPE zcl_alloc_request_validator=>ty_request_tt.

    APPEND request( iv_matnr    = 'MAT-1'
                    iv_werks    = '1000'
                    iv_quantity = '10' ) TO lt_requests.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->validate( lt_requests ) ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_requests TYPE zcl_alloc_request_validator=>ty_request_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->validate( lt_requests ) ).
  ENDMETHOD.

  METHOD empty_material.
    DATA lt_requests TYPE zcl_alloc_request_validator=>ty_request_tt.

    APPEND request( iv_matnr    = ''
                    iv_werks    = '1000'
                    iv_quantity = '10' ) TO lt_requests.

    DATA(lt_issues) = mo_cut->validate( lt_requests ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-field_name
                                        exp = 'MATNR' ).
  ENDMETHOD.

  METHOD empty_plant.
    DATA lt_requests TYPE zcl_alloc_request_validator=>ty_request_tt.

    APPEND request( iv_matnr    = 'MAT-1'
                    iv_werks    = ''
                    iv_quantity = '10' ) TO lt_requests.

    DATA(lt_issues) = mo_cut->validate( lt_requests ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-field_name
                                        exp = 'WERKS' ).
  ENDMETHOD.

  METHOD zero_quantity.
    DATA lt_requests TYPE zcl_alloc_request_validator=>ty_request_tt.

    APPEND request( iv_matnr    = 'MAT-1'
                    iv_werks    = '1000'
                    iv_quantity = '0' ) TO lt_requests.

    DATA(lt_issues) = mo_cut->validate( lt_requests ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-field_name
                                        exp = 'QUANTITY' ).
  ENDMETHOD.

  METHOD negative_quantity.
    DATA lt_requests TYPE zcl_alloc_request_validator=>ty_request_tt.

    APPEND request( iv_matnr    = 'MAT-1'
                    iv_werks    = '1000'
                    iv_quantity = '-5' ) TO lt_requests.

    DATA(lt_issues) = mo_cut->validate( lt_requests ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
  ENDMETHOD.

  METHOD multiple_issues.
    DATA lt_requests TYPE zcl_alloc_request_validator=>ty_request_tt.

    APPEND request( iv_matnr    = ''
                    iv_werks    = ''
                    iv_quantity = '0' ) TO lt_requests.

    DATA(lt_issues) = mo_cut->validate( lt_requests ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-index exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 2 ]-field_name
                                        exp = 'WERKS' ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 3 ]-field_name
                                        exp = 'QUANTITY' ).
  ENDMETHOD.

ENDCLASS.
