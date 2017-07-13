package esgi.project.wehud.adapter;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.squareup.picasso.Picasso;

import java.util.List;

import esgi.project.wehud.R;
import esgi.project.wehud.activity.GameActivity;
import esgi.project.wehud.model.Game;

/**
 * This {@link android.support.v7.widget.RecyclerView.Adapter} subclass
 * is used for displaying a list of {@link Game} objects.
 *
 * @author Olivier Gonçalves
 */
public final class GameListAdapter extends RecyclerView.Adapter<GameListAdapter.GameListVH> {

    private static final String KEY_GAME = "game";

    private List<Game> mGameList;

    public GameListAdapter(List<Game> gameList) {
        mGameList = gameList;
    }

    @Override
    public GameListVH onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.game, parent, false);
        return new GameListVH(view);
    }

    @Override
    public void onBindViewHolder(final GameListVH holder, int position) {
        final Game game = mGameList.get(position);

        String image = game.getBoxart();

        if (!TextUtils.isEmpty(image)) {
            Picasso.with(holder.context).load(image).into(holder.gameImage);
            holder.gameImage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent intent = new Intent(holder.context, GameActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putParcelable(KEY_GAME, game);
                    intent.putExtras(bundle);
                    holder.context.startActivity(intent);
                }
            });
        }
    }

    @Override
    public int getItemCount() {
         return mGameList.size();
    }

    static class GameListVH extends RecyclerView.ViewHolder {
        private Context context;
        private ImageView gameImage;

        GameListVH(View view) {
            super(view);
            this.context = view.getContext();
            this.gameImage = (ImageView) view.findViewById(R.id.game_image);
        }
    }
}
