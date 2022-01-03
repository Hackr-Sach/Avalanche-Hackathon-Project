    import { createSlice } from "@reduxjs/toolkit";

    const initialState = [""]
      

    const keysSlice = createSlice({
        name: 'keys',
        initialState,
        reducers: {
            keysAdded: {
                reducer(state: any, action: any){
                  state.push(action.payload);
                },
                prepare(address){
                    return {payload: address}
                }
            },
            // add reducers
        }
    })

    export const { keysAdded } = keysSlice.actions; 
    export default keysSlice.reducer;