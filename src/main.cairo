%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.alloc import alloc

# edge list implementation of a graph
# the graph assumes there are felt.SIZE nodes so it only stores edges

struct edge:
    member src : felt
    member dst : felt
end

@storage_var
func edges(edge_id : felt) -> (e : edge):
end

@storage_var
func last_edge_id() -> (edge_id : felt):
end

@external
func add_edge {
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        _src : felt, 
        _dst : felt
    ) -> (edge_id : felt):
    let (last_id) = last_edge_id.read()
    last_edge_id.write(last_id + 1)
    let (new_id) = last_edge_id.read()

    let e = edge(_src, _dst)
    edges.write(new_id, e)
    return (new_id)
end

# check if an edge exists between two nodes
@external
func are_adjacent{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    _src : felt, 
    _dst : felt,
    _last_edge_id : felt
) -> (connected : felt):
    alloc_locals
    if _last_edge_id == 0:
        return (0)
    end

    let (e) = edges.read(_last_edge_id)
    
    let last_edge_src = e.src
    let last_edge_dst = e.dst

    if last_edge_src == _src:
        if last_edge_dst == _dst:
            return (1)
        end
    end 

    return are_adjacent(_src, _dst, _last_edge_id - 1)
end

# reachability DFS implementation
@external
func reachable{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    _src : felt, 
    _dst : felt,
    _discovered_len : felt,
    _discovered : felt*
) -> (connected : felt, new_discovered_len : felt): 
    alloc_locals

    assert _discovered[_discovered_len] = _src

    let (is_discovered) = contains(_discovered_len + 1, _discovered, _dst)
    if is_discovered == 1:
        return (1, _discovered_len + 1)
    end

    let (edge_n) = last_edge_id.read()

    let (b, new_discovered_len) = inner_function(_src, _dst, _discovered_len + 1, _discovered, edge_n)

    return (b, new_discovered_len)
end

func inner_function{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(
    _src : felt, 
    _dst : felt,
    _discovered_len : felt,
    _discovered : felt*,
    edge_id : felt
) -> (connected : felt, new_discovered_len : felt):
    alloc_locals

    if edge_id == 0:
        return (0, _discovered_len)
    end


    let (e) = edges.read(edge_id)  # get an edge from the edge list
    if e.src == _src:
        let adjacent = e.dst          # get the adjacent node
        let (is_discovered) = contains(_discovered_len, _discovered, adjacent) # check if the adjacent node is already discovered
        if is_discovered == 0:
            let (r, new_discovered_len) = reachable(adjacent, _dst, _discovered_len, _discovered)     # recursively call reachability from the adjacent node
            if r == 1:
                return (1, new_discovered_len)
            else:
                return inner_function(_src, _dst, new_discovered_len, _discovered, edge_id - 1)
            end
        else:
            tempvar syscall_ptr = syscall_ptr
            tempvar pedersen_ptr = pedersen_ptr
            tempvar range_check_ptr = range_check_ptr
        end
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    let (b, new_discovered_len) = inner_function(_src, _dst, _discovered_len, _discovered, edge_id - 1)
    
    return (b, new_discovered_len)
end

func contains{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(arr_len : felt, arr : felt*, _val : felt) -> (b : felt):
    if arr_len == 0:
        return (0)
    end
    if arr[arr_len - 1] == _val:
        return (1)
    end
    return contains(arr_len - 1, arr, _val)
end