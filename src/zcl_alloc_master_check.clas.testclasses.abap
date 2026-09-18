CLASS ltcl_alloc_master_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_master_check.

    METHODS setup.

    METHODS add_request
      IMPORTING
        it_requests        TYPE zcl_alloc_master_check=>ty_request_tt
        iv_matnr           TYPE matnr
        iv_werks           TYPE werks_d
      RETURNING
        VALUE(rt_requests) TYPE zcl_alloc_master_check=>ty_request_tt.

    METHODS all_known       FOR TESTING.
    METHODS empty_requests  FOR TESTING.
    METHODS unknown_material FOR TESTING.
    METHODS unknown_plant   FOR TESTING.
    METHODS both_unknown    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_master_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_master_check( ).
  ENDMETHOD.

  METHOD add_request.
    DATA ls_row TYPE zcl_alloc_master_check=>ty_request.

    rt_requests = it_requests.
    ls_row-matnr = iv_matnr.
    ls_row-werks = iv_werks.
    APPEND ls_row TO rt_requests.
  ENDMETHOD.

  METHOD all_known.
    DATA lt_requests  TYPE zcl_alloc_master_check=>ty_request_tt.
    DATA lt_materials TYPE zcl_alloc_master_check=>ty_matnr_tt.
    DATA lt_plants    TYPE zcl_alloc_master_check=>ty_werks_tt.
    DATA ls_input     TYPE zcl_alloc_master_check=>ty_input.

    lt_requests = add_request( it_requests = lt_requests
                               iv_matnr    = 'MAT-1'
                               iv_werks    = '1000' ).
    APPEND 'MAT-1' TO lt_materials.
    APPEND '1000' TO lt_plants.

    ls_input-requests = lt_requests.
    ls_input-materials = lt_materials.
    ls_input-plants = lt_plants.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->check( ls_input ) ).
  ENDMETHOD.

  METHOD empty_requests.
    DATA lt_requests  TYPE zcl_alloc_master_check=>ty_request_tt.
    DATA lt_materials TYPE zcl_alloc_master_check=>ty_matnr_tt.
    DATA lt_plants    TYPE zcl_alloc_master_check=>ty_werks_tt.
    DATA ls_input     TYPE zcl_alloc_master_check=>ty_input.

    ls_input-requests = lt_requests.
    ls_input-materials = lt_materials.
    ls_input-plants = lt_plants.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->check( ls_input ) ).
  ENDMETHOD.

  METHOD unknown_material.
    DATA lt_requests  TYPE zcl_alloc_master_check=>ty_request_tt.
    DATA lt_materials TYPE zcl_alloc_master_check=>ty_matnr_tt.
    DATA lt_plants    TYPE zcl_alloc_master_check=>ty_werks_tt.
    DATA ls_input     TYPE zcl_alloc_master_check=>ty_input.

    lt_requests = add_request( it_requests = lt_requests
                               iv_matnr    = 'MAT-X'
                               iv_werks    = '1000' ).
    APPEND 'MAT-1' TO lt_materials.
    APPEND '1000' TO lt_plants.

    ls_input-requests = lt_requests.
    ls_input-materials = lt_materials.
    ls_input-plants = lt_plants.

    DATA(lt_issues) = mo_cut->check( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-message
                                        exp = 'Material master is missing' ).
  ENDMETHOD.

  METHOD unknown_plant.
    DATA lt_requests  TYPE zcl_alloc_master_check=>ty_request_tt.
    DATA lt_materials TYPE zcl_alloc_master_check=>ty_matnr_tt.
    DATA lt_plants    TYPE zcl_alloc_master_check=>ty_werks_tt.
    DATA ls_input     TYPE zcl_alloc_master_check=>ty_input.

    lt_requests = add_request( it_requests = lt_requests
                               iv_matnr    = 'MAT-1'
                               iv_werks    = '9999' ).
    APPEND 'MAT-1' TO lt_materials.
    APPEND '1000' TO lt_plants.

    ls_input-requests = lt_requests.
    ls_input-materials = lt_materials.
    ls_input-plants = lt_plants.

    DATA(lt_issues) = mo_cut->check( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-message
                                        exp = 'Plant is missing' ).
  ENDMETHOD.

  METHOD both_unknown.
    DATA lt_requests  TYPE zcl_alloc_master_check=>ty_request_tt.
    DATA lt_materials TYPE zcl_alloc_master_check=>ty_matnr_tt.
    DATA lt_plants    TYPE zcl_alloc_master_check=>ty_werks_tt.
    DATA ls_input     TYPE zcl_alloc_master_check=>ty_input.

    lt_requests = add_request( it_requests = lt_requests
                               iv_matnr    = 'MAT-X'
                               iv_werks    = '9999' ).

    ls_input-requests = lt_requests.
    ls_input-materials = lt_materials.
    ls_input-plants = lt_plants.

    DATA(lt_issues) = mo_cut->check( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
