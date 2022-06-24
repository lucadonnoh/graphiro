%lang starknet
from src.main import edges, last_edge_id, add_edge, are_adjacent, contains, reachable
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

@view
func test_deploy{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    assert 1 = 1
    return ()
end

@view
func test_add_edge{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals

    add_edge('a', 'b')
    let (last_id) = last_edge_id.read()
    assert last_id = 1

    let (a_b) = are_adjacent('a', 'b', last_id)
    assert a_b = 1

    let (b_a) = are_adjacent('b', 'a', last_id)
    assert b_a = 0

    let (c_d) = are_adjacent('c', 'd', last_id)
    assert c_d = 0

    return ()
end

@view
func test_double_edge{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals

    add_edge('a', 'b')
    add_edge('b', 'a')

    let (last_id) = last_edge_id.read()

    let (a_b) = are_adjacent('a', 'b', last_id)
    assert a_b = 1

    let (b_a) = are_adjacent('b', 'a', last_id)
    assert b_a = 1

    return ()
end

@view
func test_contains{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals

    let (local arr : felt*) = alloc()
    assert arr[0] = 0
    assert arr[1] = 4
    assert arr[2] = 2
    assert arr[3] = 6
    assert arr[4] = 9

    let arr_len = 5

    let (is_there_6) = contains(arr_len, arr, 6)
    assert is_there_6 = 1

    let (is_there_7) = contains(arr_len, arr, 7)
    assert is_there_7 = 0

    return ()
end

@view 
func test_reachable_with_adjacent{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals

    let (local discovered : felt*) = alloc()
    
    add_edge('a', 'b')
    let (b, _) = reachable('a', 'b', 0, discovered)
    assert b = 1

    return ()
end

@view
func test_reachable_with_complex_graph{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    

    # a───►b─────────┐
    # │    │         │
    # │    │         │
    # ▼    ▼         ▼
    # c───►d───►e───►f


    add_edge('a', 'b')
    add_edge('a', 'c')
    add_edge('b', 'd')
    add_edge('c', 'd')
    add_edge('d', 'e')
    add_edge('e', 'f')
    add_edge('b', 'f')

    # check same node
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'a', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('b', 'b', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'c', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('d', 'd', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('e', 'e', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('f', 'f', 0, discovered)
    assert 1 = b

    # check adjacents first
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'b', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'c', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('b', 'd', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'd', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('d', 'e', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('e', 'f', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('b', 'f', 0, discovered)
    assert 1 = b

    # check paths of length 2
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'd', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'f', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('b', 'e', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'e', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('d', 'f', 0, discovered)
    assert 1 = b

    # check paths of length 3
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'e', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('b', 'f', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'f', 0, discovered)
    assert 1 = b

    # check paths of length 4
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'f', 0, discovered)
    assert 1 = b

    # check non existent paths
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('b', 'a', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'a', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('d', 'b', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('d', 'c', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('e', 'd', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('f', 'e', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('f', 'b', 0, discovered)
    assert 0 = b

    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('f', 'a', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('x', 'y', 0, discovered)
    assert 0 = b

    return ()

end

@view
func test_reachable_with_cycles{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals

    # a◄───d───►e
    # │    ▲
    # │    │
    # ▼    │
    # b───►c


    add_edge('a', 'b')
    add_edge('b', 'c')
    add_edge('c', 'd')
    add_edge('d', 'a')
    add_edge('d', 'e')

    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'a', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'b', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'c', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'd', 0, discovered)
    assert 1 = b

    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('b', 'b', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('b', 'c', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('b', 'd', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('b', 'a', 0, discovered)
    assert 1 = b

    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'c', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'd', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'a', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'b', 0, discovered)
    assert 1 = b

    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('d', 'd', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('d', 'a', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('d', 'b', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('d', 'c', 0, discovered)
    assert 1 = b

    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('d', 'e', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('e', 'e', 0, discovered)
    assert 1 = b

    # check non existent paths
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'x', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('x', 'a', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('e', 'd', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('e', 'a', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('e', 'b', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('e', 'c', 0, discovered)
    assert 0 = b

    return ()
end

@view
func test_reachable_with_two_graphs{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals

    # a───►b
    # 
    # c───►d

    add_edge('a', 'b')
    add_edge('c', 'd')

    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'a', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'b', 0, discovered)
    assert 1 = b

    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'c', 0, discovered)
    assert 1 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'd', 0, discovered)
    assert 1 = b

    # check non existent paths
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'c', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('a', 'd', 0, discovered)
    assert 0 = b

    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'a', 0, discovered)
    assert 0 = b
    let (local discovered : felt*) = alloc()
    let (b, _) = reachable('c', 'b', 0, discovered)
    assert 0 = b

    return ()
end



