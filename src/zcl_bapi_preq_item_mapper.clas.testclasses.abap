CLASS ltcl_bapi_preq_item_mapper DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS maps_selected_vendor FOR TESTING.
ENDCLASS.

CLASS ltcl_bapi_preq_item_mapper IMPLEMENTATION.
  METHOD maps_selected_vendor.
    zcl_bapi_preq_item_mapper=>map_items(
      EXPORTING
        it_items      = VALUE #(
          ( item_number        = '00010'
            source_vendor      = '0000100001'
            source_info_record = '0000001234'
            purchasing_org     = '2000'
            material           = 'MAT-SOURCE'
            plant              = '1000'
            quantity           = '2.000'
            unit               = 'EA'
            delivery_date      = '20261115' )
          ( item_number   = '00020'
            material      = 'MAT-AUTO'
            plant         = '1000'
            quantity      = '1.000'
            unit          = 'EA'
            delivery_date = '20261116' ) )
      IMPORTING
        et_items      = DATA(lt_bapi_items)
        et_item_flags = DATA(lt_item_flags) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_bapi_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_bapi_items[ 1 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lt_bapi_items[ 1 ]-info_rec ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_bapi_items[ 1 ]-purch_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 1 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 1 ]-info_rec ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_item_flags[ 1 ]-purch_org ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_bapi_items[ 2 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_bapi_items[ 2 ]-info_rec ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_item_flags[ 2 ]-fixed_vend ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_item_flags[ 2 ]-info_rec ).
  ENDMETHOD.
ENDCLASS.
