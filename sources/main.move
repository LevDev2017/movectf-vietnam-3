module movectf::coin2 {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use movectf::counter::{Self, Counter};

    use sui::transfer;
    use sui::event;

    struct Coin1 has store, copy {
        value: u64
    }

    struct Coin2 has store, drop {
        value: u64
    }

    struct Vault has key, store {
        id: UID,
        coin: Coin1,
        king_coin: Coin2
    }

    fun init(ctx: &mut TxContext) {
        counter::create_counter(ctx);

        transfer::share_object(Vault {
            id: object::new(ctx),
            coin: Coin1 {
                value: 100
            },
            king_coin: Coin2 {
                value: 1000
            }
        });
    }

    fun take1(vault: &mut Vault, amount: u64): Coin1 {
        vault.coin.value = vault.coin.value - amount;
        Coin1 {value: amount}
    }

    fun take2(vault: &mut Vault, amount: u64): Coin2 {
        vault.king_coin.value = vault.king_coin.value - amount;
        Coin2 {value: amount}
    }

    public fun faucet(vault: &mut Vault): Coin1 {
        let amount = vault.coin.value;
        take1(vault, amount)
    }

    public fun swap(coin: Coin1): Coin2 {
        let Coin1 { value } = coin;
        Coin2 {value}
    }

    public fun compare(vault: &mut Vault, coin: Coin2): bool {
        let amount = coin.value;
        let king_coin = take2(vault, amount);
        if (king_coin.value != coin.value) {
            king_coin.value = king_coin.value + amount;
        };
        true
    }


    struct Flag has copy, drop {
        user: address,
        flag: bool
    }

    public fun merge(base: &mut Coin1, coin: Coin1){
        let Coin1 { value } = coin;
        base.value = base.value + value;
    }

    public fun split(base: &mut Coin1, amount: u64): Coin1 {
        base.value = base.value - amount;
        Coin1 { value: amount}
    }

    public fun get_flag(user_counter: &mut Counter, vault: &mut Vault, coin1: Coin1, ctx: &mut TxContext) {
        counter::increment(user_counter);
        counter::is_within_limit(user_counter);

        let Coin1 {value} = coin1;
        assert!(value > 1000, 0);
        assert!(vault.king_coin.value == 0, 0);
        event::emit(Flag {
            user: tx_context::sender(ctx),
            flag: true
        })
    }
}
