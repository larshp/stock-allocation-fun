REPORT zstock_alloc_move.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr.
PARAMETERS p_prop TYPE zstock_alloc_trf-proposal.
PARAMETERS p_raise AS CHECKBOX.
PARAMETERS p_tidy AS CHECKBOX.
PARAMETERS p_test AS CHECKBOX DEFAULT 'X'.

START-OF-SELECTION.

  TRY.
      DATA(lo_list) = zcl_alloc_move_list=>create_default( ).

      " naming a proposal is answering it; ticking the box closes the ones
      " whose shortage has gone; naming neither is reading the list. Three
      " screens for three verbs would be three programs to find, and all
      " three are done while looking at the same list.
      IF p_prop IS NOT INITIAL.
        DATA(lt_line) = lo_list->answer(
          iv_werks    = p_werks
          iv_proposal = p_prop
          iv_raised   = p_raise ).
      ELSEIF p_tidy = abap_true.
        lt_line = lo_list->tidy(
          iv_werks = p_werks
          iv_test  = p_test ).
      ELSE.
        lt_line = lo_list->run(
          iv_werks = p_werks
          iv_matnr = p_matnr ).
      ENDIF.
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
