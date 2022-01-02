    import { createSlice } from "@reduxjs/toolkit";

    const initialState = [
        { 
          address: '0xoyugb7iy...',
          pubK: '087togho86f....'
        },
        { 
          address: '0xo6riy...',
          pubK: 'f9oiygdrftg...'
        }
      ]
      

    const keysSlice = createSlice({
        name: 'keys',
        initialState,
        reducers: {
            keysAdded: {
                reducer(state: any, action: any){
                  state.push(action.payload);
                },
                prepare(address, pubK){
                    return{
                        payload: {
                            address,
                            pubK
                        }
                    }
                }
            },
            // add reducers
        }
    })

    export const { keysAdded } = keysSlice.actions; 
    export default keysSlice.reducer;